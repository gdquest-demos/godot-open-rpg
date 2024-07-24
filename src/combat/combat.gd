## A container for the combat 'state' that cleanly handles the transition to and from combat.
##
## The battle is composed mainly from a [CombatArena], which contains all necessary subelements such
## as battlers, visual effects, music, etc.
##
## This container handles the logic of switching between the field game state, the combat game
## state, and the combat results screen (e.g. experience and levelling up, loot, etc.). It is
## responsible for changing the music, playing screen transition animations, and other state-switch
## elements.
extends CanvasLayer

var _active_arena: CombatArena = null

# Keep track of what music track was playing previously, and return to it once combat has finished.
var _previous_music_track: AudioStream = null

@onready var _combat_container: = $CenterContainer as CenterContainer
@onready var _transition_delay_timer: = $CenterContainer/TransitionDelay as Timer


func _ready() -> void:
	FieldEvents.combat_triggered.connect(start)


## Begin a combat if one isn't currently underway.
## Takes a PackedScene as its only parameter, expecting it to be a CombatState object once
## instantiated.
## This is normally a response to [signal FieldEvents.combat_triggered].
func start(arena: PackedScene) -> void:
	assert(not _active_arena, "Attempting to start a combat while one is ongoing!")
	
	# Cover the screen.
	await Transition.cover(0.2)
	
	# Try to setup the combat arena (which comes with AI battlers, etc.). 
	var new_arena: = arena.instantiate()
	assert(new_arena is CombatArena,
		"Failed to initiate combat. Provided 'arena' arugment is not a CombatArena.")
	
	_active_arena = new_arena
	_combat_container.add_child(_active_arena)
	
	_active_arena.turn_queue.finished.connect(
		func(is_player_victory: bool):
			CombatEvents.did_player_win_last_combat = is_player_victory
			_transition_delay_timer.start()
			await _transition_delay_timer.timeout
			finish()
	)
	
	_previous_music_track = Music.get_playing_track()
	Music.play(_active_arena.music)
	
	# Let other systems know that the combat state is setup and ready to begin.
	CombatEvents.combat_initiated.emit()
	
	# Before starting combat itself, reveal the screen again.
	# The Transition.clear() call is deferred since it follows on the heels of cover(), and needs a
	# frame to allow everything else to respond to Transition.finished.
	Transition.clear.call_deferred(0.2)
	await Transition.finished
	
	# Begin the combat logic by setting the turn queue (and all battlers) as active.
	_active_arena.turn_queue.is_active = true


func finish() -> void:
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
