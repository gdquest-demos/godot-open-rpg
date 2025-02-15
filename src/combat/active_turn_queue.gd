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

## The slow-motion value of [time_scale] used when the player is navigating action/target menus.
const SLOW_TIME_SCALE: = 0.05

## Emitted once a player has won or lost a battle, indicating whether or not it may be considered a 
## victory for the player. All combat animations have finished playing.
signal combat_finished(is_player_victory: bool)

## Allows pausing the Active Time Battle during combat intro, a cutscene, or combat end.
var is_active: = true:
	set(value):
		if value != is_active:
			is_active = value
			for battler in battlers.get_all_battlers():
				battler.is_active = is_active

## A list of the combat participants, in [BattlerList] form. This object is created by the turn
## queue from children [Battler]s and then made available to other combat systems.
var battlers: BattlerList

## Battlers may select their action at any point, where they will be cached in this dictionary.
## The battlers will not act, however, until the queue receives their [signal Battler.ready_to_act]
## signal and validates the action.[br][br]
## Key = Battler, Value = named dictionary with two entries: 'action' and 'targets'.
var _cached_actions: = {}

# Multiplier for the global pace of battle, to slow down time while the player is making decisions.
# This is meant for accessibility and to control difficulty. It is set according to combat state,
# as follows:
#     - _time_scale is 1 during normal gameplay.
#     - _time_scale is [const SLOW_TIME_SCALE] when the player has a menu open.
#     - _time_scale is 0 whenver an action is being executed.
var _time_scale: = 1.0:
	set(value):
		_time_scale = value
		for battler in battlers.get_all_battlers():
			battler.time_scale = _time_scale

# Tracks which [BattlerAction] is currently running. _active_action is null if no action is running.
var _active_action: BattlerAction = null:
	set(value):
		_active_action = value
		_update_time_scale()

# Tracks whether or not the player has a menu open at any given moment.
var _is_player_menu_open: = false:
	set(value):
		_is_player_menu_open = value
		_update_time_scale()


func _ready() -> void:
	# The time scale slows down whenever the user is picking an action. Connect to UI signals here
	# to adjust accordingly to whether or not the play is navigating the target/action menus.
	CombatEvents.player_battler_selected.connect(
		func _on_player_battler_selected(battler: Battler):
			_is_player_menu_open = battler != null
	)
	CombatEvents.action_selected.connect(
		# The player has fashioned an action for their Battler. Cache it now.
		func _on_action_selected(action: BattlerAction, source: Battler, targets: Array[Battler]):
			# If the action passed is null, unqueue the source Battler from any cached actions.
			if action == null:
				_cached_actions.erase(source)
			
			else:
				# Otherwise, cache the action for execution whenever the Battler is ready to act.
				_cached_actions[source] = {"action" = action, "targets" = targets}
				
				# Note that the battler only emits its ready_to_act signal once upon reaching 100
				# readiness. If the battler is currently ready to act, re-emit the signal now.
				if source.is_ready_to_act():
					source.ready_to_act.emit.call_deferred()
	)
	
	# Combat participants are children of the ActiveTurnQueue. Create the data structure that will
	# track battlers and be passed across states.
	# Note that we first need to assign typed arrays from the untyped return of get_children() in
	# order to create the combat participant structure.
	var players: Array[Battler]
	players.assign(get_children().filter(func(i): return i.is_player))
	var enemies: Array[Battler]
	enemies.assign(get_children().filter(func(i): return !i.is_player))
	
	battlers = BattlerList.new(players, enemies)
	battlers.battlers_downed.connect(
		# Begin the shutdown sequence for the combat, flagging end of the combat logic.
		# This is called immediately when the player has either won or lost the combat.
		func _on_combat_side_downed() -> void:
			# On combat end, a number of systems will animate out (the UI fades, for example).
			# However, the battlers also end with animations: celebration or death animations. The 
			# combat cannot truly end until these animations have finished, so wait for children 
			# Battlers to 'wrap up' from this point onwards.
			# This is done with the ActiveTurnQueue's process function, which will check each frame
			# to see if the losing team's final animations have finished.
			set_process(true)
			
			# Don't allow anyone else to act.
			is_active = false
	)
	
	for battler in battlers.get_all_battlers():
		# Setup Battler AIs to make use of the BattlerList object (needed to pick targets).
		if battler.ai != null:
			battler.ai.setup(battler, battlers)
		
		# Battlers will act as their ready_to_act signal is emitted. The turn queue will allow them 
		# to act if another action is not currently underway.
		battler.ready_to_act.connect(_on_battler_ready_to_act.bind(battler))
		
		# Remove any cached actions whenever the Battler is downed.
		battler.health_depleted.connect(
			(func _on_battler_health_depleted(downed_battler: Battler):
				_cached_actions.erase(downed_battler)).bind(battler)
		)
	
	# The ActiveTurnQueue uses _process to wait for animations to finish at combat end, so disable
	# _process for now.
	set_process(false)
	
	# Don't begin combat until the state has been setup. I.e. intro animations, UI is ready, etc.
	is_active = false


# The active turn queue waits until all battlers have finished their animations before emitting the
# finished signal.
func _process(_delta: float) -> void:
	# Only track the animations of the losing team, as the winning team will animate their idle
	# poses indefinitely.
	var tracked_battlers: Array[Battler] = battlers.enemies if battlers.has_player_won \
		else battlers.players
	
	for child: Battler in tracked_battlers:
		# If there are still playing BattlerAnims, don't finish the battle yet.
		if child.anim.is_playing():
			return

	# There are no defeat animations being played. Combat can now finish.
	set_process(false)
	combat_finished.emit(battlers.has_player_won)


# The time scale is affected by the player navigating menus and actions being played. Update the
# time scale to 
func _update_time_scale() -> void:
	if _active_action != null:
		_time_scale = 0
	elif _is_player_menu_open:
		_time_scale = SLOW_TIME_SCALE
	else:
		_time_scale = 1


# When a Battler emits its ready_to_act signal, check to see if it can act. The action must be valid
# and there must not be another ongoing action.
func _on_battler_ready_to_act(battler: Battler):
	if _active_action != null:
		return
	
	# Check, first of all, to see if there is a cached action registered to this Battler.
	var action_data: Dictionary = _cached_actions.get(battler, {})
	
	# If so, check to see if the action is valid, in which case it will execute.
	if not action_data.is_empty():
		var action: BattlerAction = action_data.action
		var targets: Array[Battler] = action_data.targets.filter(
			func(target: Battler): return action.can_target_battler(target)
		)
		
		if action.can_execute(battler, targets):
			_cached_actions.erase(battler)
			_active_action = action
			await battler.act(action, targets)
			_active_action = null
