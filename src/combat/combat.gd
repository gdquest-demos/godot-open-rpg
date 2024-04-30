extends CanvasLayer

var _active_arena: CombatArena = null

# Keep track of what music track was playing previously, and return to it once combat has finished.
var _previous_music_track: AudioStream = null

@onready var _combat_containter: = $CenterContainer as CenterContainer


func _ready() -> void:
	FieldEvents.combat_triggered.connect(start)
	
	# TODO: remove with _unhandled input once Battlers have been implemented.
	set_process_unhandled_input(false)


# TODO: This is included to allow leaving the combat state.
# In future releases, these signals will be emitted once battlers from one side have fallen.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("back"):
		CombatEvents.did_player_win_last_combat = false
		finish()
	
	elif event.is_action_released("interact"):
		CombatEvents.did_player_win_last_combat = true
		finish()


func start(arena: PackedScene) -> void:
	assert(not _active_arena, "Attempting to start a combat when one is ongoing!")
	
	# Cover the screen.
	await Transition.cover(0.2)
	
	# Try to setup the combat arena (which comes with AI battlers, etc.). 
	var new_arena: = arena.instantiate()
	assert(new_arena is CombatArena,
		"Failed to initiate combat. Provided 'arena' arugment is not a CombatArena.")
	
	_active_arena = new_arena
	_combat_containter.add_child(_active_arena)
	
	_previous_music_track = Music.get_playing_track()
	Music.play(_active_arena.music)
	
	# Let other systems know that the combat state is setup and ready to begin.
	CombatEvents.combat_initiated.emit()
	
	# Before starting combat itself, reveal the screen again.
	# The Transition.clear() call is deferred since it follows on the heels of cover(), and needs a
	# frame to allow everything else to respond to Transition.finished.
	Transition.clear.call_deferred(0.2)
	await Transition.finished
	
	# TODO: remove with _unhandled input once Battlers have been implemented.
	set_process_unhandled_input(true)


func finish() -> void:
	# TODO: remove with _unhandled input once Battlers have been implemented.
	set_process_unhandled_input(false)
	
	if not _active_arena:
		return
	
	# Cover the screen again, transitioning away from the combat game state.
	await Transition.cover(0.2)
	
	_active_arena.queue_free()
	_active_arena = null
	
	Music.play(_previous_music_track)
	_previous_music_track = null
	
	# Signal that the combat has been finished and all combat objects have been dealt with
	# accordingly. The field game 'state' will now be in focus.
	# Note that whatever object started the combat will now be responsible for flow of the game. In
	# particular, the screen is still covered, so the combat-starting object will want to decide
	# what to do now that the outcome of the combat is known.
	CombatEvents.combat_finished.emit()
