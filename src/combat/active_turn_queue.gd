## Responsible for [Battler]s, managing their turns, action order, and lifespans.
##
## The ActiveTurnQueue sorts Battlers neatly into a queue as they are ready to act. Time is paused
## as Battlers act and is resumed once actors have finished acting. The queue ceases once the player
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
			for battler in battlers.get_all_battlers():
				battler.is_active = is_active

## Multiplier for the global pace of battle, to slow down time while the player is making decisions.
## This is meant for accessibility and to control difficulty.
var time_scale: = 1.0:
	set(value):
		time_scale = value
		for battler in battlers.get_all_battlers():
			battler.time_scale = time_scale

# If true, the player is currently playing a turn (navigating menus, choosing targets, etc.).
var _is_player_playing: = false

# Actions may be placed in the following queue and will be exectued in order by the ActiveTurnQueue.
# This prevents actions from being executed concurrently.
var _actions: = {}

## A stack of player-controlled battlers that have to take turns.
var _queued_player_battlers: Array[Battler] = []

## A list of the combat participants, in [CombatTeamData] form. This object is created by the turn
## queue from children [Battler]s and then made available to other combat systems.
var battlers: CombatTeamData


func _ready() -> void:
	battlers = CombatTeamData.new()
	battlers.player_battlers.assign(get_children().filter(func(i): return i.is_player))
	battlers.enemies.assign(get_children().filter(func(i): return !i.is_player))
	
	battlers.player_battlers_downed.connect(_on_combat_side_downed)
	battlers.enemy_battlers_downed.connect(_on_combat_side_downed)
	
	# The ActiveTurnQueue uses _process to wait for animations to finish at combat end, so disable
	# _process for now.
	set_process(false)

	#player_turn_finished.connect(func _on_player_turn_finished() -> void:
		#if _queued_player_battlers.is_empty():
			#_is_player_playing = false
		#else:
			#_play_turn(_queued_player_battlers.pop_front())
		#)
#
	#for battler: Battler in combat_data.get_all_battlers():
		#battler.ready_to_act.connect(func on_battler_ready_to_act() -> void:
			#if battler.is_player and _is_player_playing:
				#_queued_player_battlers.append(battler)
			#else:
				#_play_turn(battler)
		#)

	# Don't begin combat until the state has been setup. I.e. intro animations, UI is ready, etc.
	is_active = false


# The active turn queue waits until all battlers have finished their animations before emitting the
# finished signal.
func _process(_delta: float) -> void:
	# Only track the animations of the losing team, as the winning team will animate their idle
	# poses indefinitely.
	var tracked_battlers: Array[Battler] = battlers.enemies if battlers.has_player_won \
		else battlers.player_battlers
	
	for child: Battler in tracked_battlers:
		# If there are still playing BattlerAnims, don't finish the battle yet.
		if child.anim.is_playing():
			return

	# There are no defeat animations being played. Combat can now finish.
	set_process(false)
	combat_finished.emit(battlers.has_player_won)


#func _play_turn(battler: Battler) -> void:
	#var action: BattlerAction
	#var targets: Array[Battler] = []
#
	## The battler is getting a new turn, so increment its energy count.
	#battler.stats.energy += 1
#
	## The code below makes a list of selectable targets using Battler.is_selectable
	#var potential_targets: Array[Battler] = []
	#var opponents: Array[Battler] \
		#= combat_data.enemies if battler.is_player else combat_data.player_battlers
	#for opponent: Battler in opponents:
		#if opponent.is_selectable:
			#potential_targets.append(opponent)
#
	#if battler.is_player:
		#_is_player_playing = true
		#battler.is_selected = true
#
		#time_scale = 0.05
#
		## Loop until the player selects a valid set of actions and targets of said action.
		#var is_selection_complete: = false
		#while not is_selection_complete:
			#CombatEvents.player_battler_selected.emit(battler)
			## First of all, the player must select an action.
			#action = await CombatEvents.player_action_selected as BattlerAction
			#if action == null: 
				#continue
#
			## Secondly, the player must select targets for the action.
			## If the target may be selected automatically, do so.
			#if action.targets_self:
				#targets = [battler]
			#else:
				##targets = await CombatEvents.player_targets_selected
				#targets = [potential_targets[0]]
#
			## If the player selected a correct action and target, break out of the loop. Otherwise,
			## the player may reselect an action/targets.
			#is_selection_complete = action != null and targets != []
#
		#battler.is_selected = false
#
	#else:
		## Allow the AI to take a turn.
		#if battler.actions.size():
			#action = battler.actions[0]
			#targets = [potential_targets[0]]
	#
	## Time should not pass while another battler is acting.
	#time_scale = 0
	#await battler.act(action, targets)
	#time_scale = 1.0
#
	#if battler.is_player:
		#player_turn_finished.emit()


# Begin the shutdown sequence for the combat, flagging end of the combat logic.
# This is called immediately when the player has either won or lost the combat.
func _on_combat_side_downed() -> void:
	# On combat end, a number of systems will animate out (the UI fades, for example).
	# However, the battlers also end with animations: celebration or death animations. The combat
	# cannot truly end until these animations have finished, so wait for children Battlers to
	# 'wrap up' from this point onwards.
	# This is done with the ActiveTurnQueue's process function, which will check each frame to see 
	# if the losing team's final animations have finished.
	set_process(true)

	# Don't allow anyone else to act.
	is_active = false
	
	# Let the normal combat UI systems know that they can fade out now.
	battlers_downed.emit()
