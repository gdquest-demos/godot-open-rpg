class_name Event
extends Area2D

signal cinematic_mode_ready

signal finished

## If [code]true[/code] the trigger will become inactive after it is triggered by a gamepiece.
@export var one_shot: = false

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

var music_player: MusicPlayer = null


func _ready() -> void:
	add_to_group(Groups.EVENTS)
	
	FieldEvents.event_ready.emit(self)


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


func _execute() -> void:
	await get_tree().process_frame
