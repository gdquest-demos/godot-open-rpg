## The Combat class manages combat logic from beginning to end.
##
## The battle is composed from several components which should all be wrapped up in a [CombatArena].
## The Combat class instantiates the arena as a child before instantiating the player battlers and
## assigning them as descendants of the arena's [BattlerRoster].[br][br]
##
## The combat logic follows the pattern set by early JRPGs, where each combat round includes two
## phases:
## [br]	1) Action selection: each Battler selects an action, AI battlers followed by the player.
## [br]	2) Action execution: the Battlers carry out their selected actions.[br][br]
## If the player and enemy sides are both still alive, combat procedes to the next round. Combat
## logic may be illustrated as follows:[br][br]
## [method setup] combat with a [CombatArena] (usually triggered by
## [signal FieldEvents.combat_triggered]).
## [br]	- Begin new combat round
## [br]		- AI Battlers select their actions.
## [br]		- Until all player Battlers have a [member Battler.cached_action]:
## [br]			- The next player Battler selects their action via the [UICombat].
## [br]			- If all player Battlers have a [member Battler.cached_action], move to action
## execution.
## [br][br]		- For each Battler with a cached action (sorted by speed):
## [br]			- [method Battler.act]
## [br]		- If player and enemy Battlers are still alive, go to the next round.[br]
## [method shutdown] combat, cleaning up combat objects
## [br]	- Emit the [signal Combat.combat_finished] signal.
extends GameState

## The arena that will be loaded for Combat. Otherwise, the value set in
## [member Combat.current_arena] will be used.
## This is useful for testing combats by running the combat game state directly. In-game, however,
## this value will not be used.
@export var arena: PackedScene

## Tracks which combat round is currently being played. Every round, all active [Battler]s will get
## a turn to act.
var round_count: int = 0

# Track the combat arena and some of the info it contains.
var _combat_arena: CombatArena

# Keep track of what music track was playing previously, and return to it once combat has finished.
var _previous_music_track: AudioStream = null

# A reference to 
@onready var _battler_roster: BattlerRoster
@onready var _combat_container: = $CenterContainer as CenterContainer
@onready var _transition_delay_timer: = $UI/TransitionDelay as Timer
@onready var _ui: = $UI as UICombat


func _ready() -> void:
	if get_parent() == get_tree().root:
		Combat.current_arena = arena
		start.call_deferred()


func start() -> void:
	var new_arena = Combat.current_arena.instantiate()
	assert(
		new_arena != null,
		"Failed to initiate combat. Provided Combat.current_arena is not a CombatArena!"
	)
	
	_combat_arena = new_arena
	_combat_container.add_child(_combat_arena)
	_battler_roster = _combat_arena.get_battler_roster()
	
	# Wait a frame for the arena and its children (VFX, Battlers, etc.) to be ready.
	await get_tree().process_frame
	
	_ui.setup(_battler_roster)

	_previous_music_track = Music.get_playing_track()
	Music.play(_combat_arena.music)

	# Before starting combat itself, reveal the screen again.
	# The Transition.clear() call is deferred since it follows on the heels of cover(), and needs a
	# frame to allow everything else to respond to Transition.finished.
	Transition.clear.call_deferred(0.2)
	await Transition.finished
	
	# Fade in the combat UI elements.
	_ui.animation.play("fade_in")
	await _ui.animation.animation_finished
	
	# Begin the combat logic. The turn queue takes over from here.
	round_count = 0
	next_round.call_deferred()


# Moves combat to the next round. At the beginning of the round, all Battlers will choose an action.
func next_round() -> void:
	round_count += 1
	
	# First of all, let enemy (necessarily AI) battlers pick their actions.
	for battler in _battler_roster.find_live_battlers(_battler_roster.get_enemy_battlers()):
		if battler.ai != null:
			battler.ai.select_action(battler)
	
	# Secondly, allow player Battlers to pick their action.
	# This will be iterative as the player selects and cancels their choices. The turn queue will
	# move to the action phase once all player Battlers have an action selected.
	_select_next_player_action()


# Player Battlers select their actions by repeatedly calling _select_next_player_action. The method
# looks for player Battlers who have no cached action and prioritizes those further up in the scene
# tree. This allows the player to go "backwards" and "forwards" between Battlers, choosing actions
# and cancelling them as needed.
# At this point, all AI Battlers should have a cached actoin.
# Once all Battlers have an action cached (see Battler.cached_action), _select_next_player_action
# calls _next_turn to move into the second phase.
func _select_next_player_action() -> void:
	# Find any remaining player Battlers that need an action selected.
	var player_battlers: = _battler_roster.get_player_battlers()
	var remaining_battlers: = _battler_roster.find_battlers_needing_actions(player_battlers)
	
	# If there are no player Battlers needing actions, move on to the second phase of a round:
	# taking action!
	if remaining_battlers.is_empty():
		# De-select the last Battler that was receiving orders.
		Combat.player_battler_selected.emit(null)
		_play_next_action.call_deferred()
		return
	
	# If there are player Battlers needing cached actions, pick the first one and allow it to search
	# for an action using either its AI controller (if present) or player input.
	var next_player_battler: Battler = remaining_battlers.front()
	
	# When the player selects an action (or presses 'back'), the current Battler needs to move back
	# to its rest position before moving on to the next battler, hence the await call below.
	next_player_battler.action_cached.connect(
		(func _on_selected_battler_action_cached(battler: Battler) -> void:
			# Check to see if the player cancelled action selection (pressed "back" from the
			# UIActionMenu). If so, the player wishes to reissue orders for the previous Battler.
			# If there IS a previous Battler, remove its cached action.
			if battler.cached_action == null:
				var battlers: = _battler_roster.get_player_battlers()
				var index: = battlers.find(battler)
				if index > 0:
					var previous_battler: Battler = battlers[index-1]
					previous_battler.cached_action = null
			
			await battler.anim.move_to_rest(0.15)
			_select_next_player_action()
			).bind(next_player_battler), 
		CONNECT_DEFERRED | CONNECT_ONE_SHOT)
	
	await next_player_battler.anim.move_forward(0.15)
	
	# Activate the player UI elements for the currently selected battler.
	Combat.player_battler_selected.emit(next_player_battler)


# The second phase of combat has each Battler act in order of speed. This is done by repeatedly
# calling _next_turn until no active Battlers have a cached action waiting to be executed.
func _play_next_action() -> void:
	# Check for battle end conditions, that one side has been downed.
	if _battler_roster.are_battlers_defeated(_battler_roster.get_player_battlers()):
		_on_combat_finished.call_deferred(false)
		return
	elif _battler_roster.are_battlers_defeated(_battler_roster.get_enemy_battlers()):
		_on_combat_finished.call_deferred(true)
		return

	# Check for an active Battler. If neither side has lost yet there are no active actors, it's
	# time to start the next round.
	var next_actor: = _get_next_actor()
	if next_actor == null:
		next_round()
		return
	
	# Connect to the actor's turn_finished signal. The actor is guaranteed to emit the signal,
	# even if it will be freed at the end of this frame.
	# However, we'll call_defer the next turn, since the current actor may have been downed on its
	# turn and we need a frame to process the change.
	next_actor.turn_finished.connect(_play_next_action, CONNECT_DEFERRED | CONNECT_ONE_SHOT)
	next_actor.act()


func _get_next_actor() -> Battler:
	var battlers: = _battler_roster.get_battlers()
	var ready_to_act_battlers: = _battler_roster.find_ready_to_act_battlers(battlers)
	if ready_to_act_battlers.is_empty():
		return null
	
	ready_to_act_battlers.sort_custom(Battler.sort)
	return ready_to_act_battlers.front()


func _on_combat_finished(is_player_victory: bool) -> void:
	if is_player_victory:
		Dialogic.VAR.set_variable("QueuedCutscene", _combat_arena.victory_cutscene)
	else:
		Dialogic.VAR.set_variable("QueuedCutscene", _combat_arena.loss_cutscene)
	
	# Fade out the combat UI elements.
	_ui.animation.play("fade_out")
	await _ui.animation.animation_finished
	#await _display_combat_results_dialog(is_player_victory)
	
	# Wait a short period of time and then fade the screen to black.
	_transition_delay_timer.start()
	await _transition_delay_timer.timeout
	await Transition.cover(0.2)

	Music.play(_previous_music_track)
	transition_executed.emit(Game.States.OVERWORLD)


## Displays a series of dialogue bubbles using Dialogic with information about the combat's outcome.
func _display_combat_results_dialog(is_player_victory: bool):
	var player_party_leader_name: = _battler_roster.get_player_battlers()[0].name

	var timeline_events: Array[String]
	if is_player_victory:
		timeline_events = _get_victory_message_events(player_party_leader_name)
	else:
		timeline_events = _get_loss_message_events(player_party_leader_name)

	var combat_rewards_timeline: DialogicTimeline = DialogicTimeline.new()
	combat_rewards_timeline.events = timeline_events
	Dialogic.start_timeline(combat_rewards_timeline)
	await Dialogic.timeline_ended


# These two functions are placeholders for future logic for deciding combat outcomes.
func _get_victory_message_events(leader_name: String) -> Array[String]:
	var events: Array[String] = [
		"%s's party won the battle!" % leader_name
	]
	events.append("You wanted to find some coins, but animals have no pockets to carry them.")
	return events
	

func _get_loss_message_events(leader_name: String) -> Array[String]:
	var events: Array[String] = [
		"%s's party lost the battle!" % leader_name
	]
	return events
