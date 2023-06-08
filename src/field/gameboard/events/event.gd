class_name Event
extends Area2D

signal cinematic_mode_ready

signal finished

@export var is_cinematic: = false

var music_player: MusicPlayer = null


func _ready() -> void:
	add_to_group(Groups.EVENTS)
	
	FieldEvents.event_ready.emit(self)


func run() -> void:
	add_to_group(Groups.ACTIVE_EVENTS)
	
	var cinematic_mode: CinematicModeListener = null
	if is_cinematic:
		cinematic_mode = CinematicModeListener.new()
		add_child(cinematic_mode)
		
		finished.connect(cinematic_mode.queue_free)
		
		await cinematic_mode.cinematic_mode_ready
	
	await _execute()
	
	remove_from_group(Groups.ACTIVE_EVENTS)
	finished.emit()


func _execute() -> void:
	await get_tree().process_frame
