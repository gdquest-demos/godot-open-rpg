class_name ActiveTurnQueue extends Node2D

## Emitted when a combat has finished, indicating whether or not it may be considered a victory for
## the player.
signal finished(is_player_victory: bool)

## Emitted when a player-controlled battler finished playing a turn. That is, when the _play_turn()
## method returns.
signal player_turn_finished

# If true, the player is currently playing a turn (navigating menus, choosing targets, etc.).
var _is_player_playing: = false

# Only ever set true if the player has won the combat. I.e. enemy battlers are felled.
var _has_player_won: = false

# A stack of player-controlled battlers that have to take turns.
var _queued_player_battlers: Array[Battler] = []

var _party_members: Array[Battler] = []
var _enemies: Array[Battler] = []

# Allows pausing the Active Time Battle during combat intro, a cutscene, or combat end.
var is_active: = true:
	set(value):
		if value != is_active:
			is_active = value
			for battler: Battler in battlers:
				battler.is_active = is_active

# Multiplier for the global pace of battle, to slow down time while the player is making decisions.
# This is meant for accessibility and to control difficulty.
var time_scale: = 1.0:
	set(value):
		time_scale = value
		for battler: Battler in battlers:
			battler.time_scale = time_scale 

@onready var battlers = get_children()


func _ready() -> void:
	set_process(false)
	
	player_turn_finished.connect(_on_player_turn_finished)
	
	for battler: Battler in battlers:
		battler.ready_to_act.connect(_on_battler_ready_to_act.bind(battler))
		battler.health_depleted.connect(_on_battler_health_depleted)
		
		if battler.is_player:
			_party_members.append(battler)
		
		else:
			_enemies.append(battler)


# The active turn queue waits until all battlers have finished their animations before emitting the
# finished signal.
func _process(_delta: float) -> void:
	print("Checking for animations.")
	for child: BattlerAnim in find_children("*", "BattlerAnim"):
		# If there are still playing BattlerAnims, don't finish the battle yet.
		if child.is_playing():
			return
	
	# There are no animations being played. Combat can now finish.
	set_process(false)
	print("Finished combat. Has player won? ", _has_player_won)
	finished.emit(_has_player_won)


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
	
	if battler.is_player_controlled():
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
	
	if battler.is_player_controlled():
		player_turn_finished.emit()


func _player_select_action_async(battler: Battler) -> BattlerAction:
	await get_tree().process_frame
	return battler.actions[0]


func _player_select_targets_async(_action: BattlerAction, 
		opponents: Array[Battler]) -> Array[Battler]:
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
	return true


func _on_battler_ready_to_act(battler: Battler) -> void:
	# If the battler is controlled by the player but another player-controlled battler is in the 
	# middle of a turn, we add this one to the stack.
	if battler.is_player_controlled() and _is_player_playing:
		_queued_player_battlers.append(battler)
	
	# Otherwise, it's an AI-controlled battler or the player is waiting for a turn.
	# The battler may act immediately.
	else:
		_play_turn(battler)


func _on_player_turn_finished() -> void:
	# When a player-controlled character finishes their turn and the stack is empty, the player is
	# no longer playing.
	if _queued_player_battlers.is_empty():
		_is_player_playing = false
	
	# Otherwise, we pop the array's first value and let the corresponding battler play their turn.
	else:
		_play_turn(_queued_player_battlers.pop_front())


# Called whenever a battler dies. Check to see if one of the 'sides' of combat is fully downed. That
# is, there are no battlers with positive health points.
func _on_battler_health_depleted() -> void:
	# Check, first of all, if the player battlers are dead. The player must survive to win.
	if not _deactivate_if_side_downed(_party_members, false):
		# The players are alive, so check to see if all enemy battlers have fallen.
		_deactivate_if_side_downed(_enemies, true)
