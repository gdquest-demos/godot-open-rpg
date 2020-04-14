# Base command interface for all actions the player 
# or a character can perform on the map
# Uses a reference to the LocalMap to start interactions
# and wait for events to complete with coroutines
extends Node

class_name MapAction

signal finished
var local_map
var active: bool = true


func _ready() -> void:
	# using a group so LocalMap can initialize all MapActions
	add_to_group("map_action")


func initialize(_local_map):
	local_map = _local_map


func interact() -> void:
	print("You forgot to override the interact method in " + name)
	emit_signal("finished")
