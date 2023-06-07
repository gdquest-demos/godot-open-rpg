class_name Event
extends Area2D

var active: = true

var music_player: MusicPlayer = null

var pause_field: Callable
var unpause_field: Callable
var mute_field: Callable
var unmute_field: Callable


func _ready() -> void:
	add_to_group(Groups.EVENTS)
	
	FieldEvents.event_ready.emit(self)


## Setup the event so that it may influence the field state itself.
func setup() -> void:
	print("Setup %s" % name)
