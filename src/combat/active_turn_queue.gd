## Responds to [Battler] and input signals to determine when and how Battlers may act.
##
## The ActiveTurnQueue sorts Battlers neatly into a queue as they are ready to act. Time is paused
## as Battlers act and is resumed once actors are finished acting. The queue ceases once the player
## or enemy Battlers have been felled, signaling that the combat has finished.
##
## Note: the turn queue defers action/target selection to either AI or player input. While
## time is slowed for player input, it is not stopped completely which may result in an AI Battler
## acting while the player is taking their turn.
class_name ActiveTurnQueue extends Node2D

## Emitted immediately once the player has won or lost the battle. Note that all animations (such
## as the player or AI battlers disappearing) are not yet completed.
## This is the point at which most UI elements will disappear.
signal battlers_downed
## Emitted once a player has won or lost a battle, indicating whether or not it may be considered a 
## victory for the player. All combat animations have finished playing.
signal combat_finished(is_player_victory: bool)
## Emitted when a player-controlled battler finished playing a turn. That is, when the _play_turn()
## method returns.
signal player_turn_finished

## Allows pausing the Active Time Battle during combat intro, a cutscene, or combat end.
var is_active: = true:
	set(value):
		if value != is_active:
			is_active = value
			for battler: Battler in _battlers:
				battler.is_active = is_active
## Multiplier for the global pace of battle, to slow down time while the player is making decisions.
## This is meant for accessibility and to control difficulty.
var time_scale: = 1.0:
	set(value):
		time_scale = value
		for battler: Battler in _battlers:
			battler.time_scale = time_scale

## If true, the player is currently playing a turn (navigating menus, choosing targets, etc.).
var _is_player_playing: = false

## Only ever set true if the player has won the combat. I.e. enemy battlers are felled.
var _has_player_won: = false

## A stack of player-controlled battlers that have to take turns.
var _queued_player_battlers: Array[Battler] = []

var _battlers: Array[Battler] = []
var _party_members: Array[Battler] = []
var _enemies: Array[Battler] = []


func _ready() -> void:
	# This is required in Godot 4.3 to strongly type the array.
	_battlers.assign(get_children())
	set_process(false)

	player_turn_finished.connect(func _on_player_turn_finished() -> void:
		if _queued_player_battlers.is_empty():
			_is_player_playing = false
		else:
			_play_turn(_queued_player_battlers.pop_front())
		)

	for battler: Battler in _battlers:
		battler.ready_to_act.connect(func on_battler_ready_to_act() -> void:
			if battler.is_player and _is_player_playing:
				_queued_player_battlers.append(battler)
			else:
				_play_turn(battler)
		)
		battler.health_depleted.connect(func on_battler_health_depleted() -> void:
			if not _deactivate_if_side_downed(_party_members, false):
				_deactivate_if_side_downed(_enemies, true)
		)

		if battler.is_player:
			_party_members.append(battler)
		else:
			_enemies.append(battler)

	# Don't begin combat until the state has been setup. I.e. intro animations, UI is ready, etc.
	is_active = false


# The active turn queue waits until all battlers have finished their animations before emitting the
# finished signal.
func _process(_delta: float) -> void:
	for child: BattlerAnim in find_children("*", "BattlerAnim"):
		# If there are still playing BattlerAnims, don't finish the battle yet.
		if child.is_playing():
			return

	# There are no animations being played. Combat can now finish.
	set_process(false)
	combat_finished.emit(_has_player_won)


func get_battlers() -> Array[Battler]:
	return _battlers


func _play_turn(battler: Battler) -> void:
	var action: BattlerAction
	var targets: Array[Battler] = []

	# The battler is getting a new turn, so increment its energy count.
	battler.stats.energy += 1

	# The code below makes a list of selectable targets using Battler.is_selectable
	var potential_targets: Array[Battler] = []
	var opponents: = _enemies if battler.is_player else _party_members
	for opponent: Battler in opponents:
		if opponent.is_selectable:
			potential_targets.append(opponent)

	if battler.is_player:
		_is_player_playing = true
		battler.is_selected = true

		time_scale = 0.05

		# Loop until the player selects a valid set of actions and targets of said action.
		var is_selection_complete: = false
		while not is_selection_complete:
			# First of all, the player must select an action.
			action = await _player_select_action_async(battler)

			# Secondly, the player must select targets for the action.
			# If the target may be selected automatically, do so.
			if action.targets_self:
				targets = [battler]
			else:
				targets = await _player_select_targets_async(action, potential_targets)

			# If the player selected a correct action and target, break out of the loop. Otherwise,
			# the player may reselect an action/targets.
			is_selection_complete = action != null and targets != []

		battler.is_selected = false

	else:
		# Allow the AI to take a turn.
		if battler.actions.size():
			action = battler.actions[0]
			targets = [potential_targets[0]]

	time_scale = 0
	await battler.act(action, targets)
	time_scale = 1.0

	if battler.is_player:
		player_turn_finished.emit()


func _player_select_action_async(battler: Battler) -> BattlerAction:
	await get_tree().process_frame
	return battler.actions[0]


func _player_select_targets_async(_action: BattlerAction, opponents: Array[Battler]) -> Array[Battler]:
	await get_tree().process_frame
	return [opponents[0]]


# Run through a provided array of battlers. If all of them are downed (that is, their health points
# are 0), finish the combat and indicate whether or not the player was victorious.
# Return true if the combat has finished, otherwise return false.
func _deactivate_if_side_downed(checked_battlers: Array[Battler],
		is_player_victory: bool) -> bool:
	for battler: Battler in checked_battlers:
		if battler.stats.health > 0:
			return false

	# If the player battlers are dead, wait for all animations to finish playing before signaling
	# a resolution to the combat.
	# This is done with this classes' process function, which will check each frame to see if any
	# 'clean up' animations have finished.
	set_process(true)
	_has_player_won = is_player_victory

	# Don't allow anyone else to act.
	is_active = false
	
	# Let the normal combat UI systems know that they can fade out now.
	battlers_downed.emit()
	return true
