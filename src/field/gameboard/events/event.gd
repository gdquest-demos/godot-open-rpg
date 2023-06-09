## A scripted sequence that changes the game state.
##
## Examples include dialogue, adding and removing characters from the field, changing the player's
## party, etc.
class_name Event
extends Area2D

signal finished

## If [code]true[/code] the event will become inactive after it is run once.
@export var one_shot: = false

## If [code]true[/code] this event will cause the field gamestate to enter 'cinematic mode', which
## is often known as a cutscene.
## In cinematic mode input methods (both AI & player) are disabled and the cinematic event will wait 
## until all gamepieces have finished travelling to execute.
## [br][br][b]Note[/b]: It is possible for multiple events to trigger cutscene mode, which may lead
## to undesirable consequences. There are several ways to resolve such a collision (run both, have
## a higher priority event run and cancel the other, etc.) which must be determined by the designer,
## since the behaviour will be specific to the game design. As it is, [i]be warned[/i] that a design
## leading to overlapping cinematic events will need to be addressed by the designer.
@export var is_cinematic: = false

## If [code]true[/code] the event will be "collidable". Otherwise, the event will not receive or
## cause collisions.
@export var is_active: = true:
	set(value):
		is_active = value
		monitoring = is_active
		monitorable = is_active
		
		if not is_inside_tree():
			await ready
		
		# We use "Visible Collision Shapes" to debug positions on the gameboard, so we'll want to
		# change the state of child collision shapes as well.
		# These could be either CollisionShape2Ds or CollisionPolygon2Ds.
		for node in find_children("*", "CollisionShape2D"):
			(node as CollisionShape2D).disabled = !is_active
		for node in find_children("*", "CollisionPolygon2D"):
			(node as CollisionPolygon2D).disabled = !is_active

## Maintain a reference to the field music player, ensuring only one track is played at a time.
var music_player: MusicPlayer = null


func _ready() -> void:
	add_to_group(Groups.EVENTS)
	
	FieldEvents.event_ready.emit(self)


## Immediately execute the event.
## [br][br]The function will emit [signal finished] when it has completed.
## [br][br]Note that run() depends entirely on [method _execute]. run() is not intended to be 
## overwritten by derived classes.
func run() -> void:
	if is_active:
		if one_shot:
			is_active = false
			
		add_to_group(Groups.ACTIVE_EVENTS)
		
		var cinematic_mode: CinematicEventHelper = null
		if is_cinematic:
			cinematic_mode = CinematicEventHelper.new()
			add_child(cinematic_mode)
			
			finished.connect(cinematic_mode.queue_free)
			
			await cinematic_mode.cinematic_mode_ready
		
		await _execute()
		
		remove_from_group(Groups.ACTIVE_EVENTS)
		finished.emit()


## _execute() is where the event will play out. It is intended to be overwritten by derived events. 
## _execute() may or may not be asynchronous.
func _execute() -> void:
	await get_tree().process_frame
