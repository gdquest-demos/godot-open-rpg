@tool
class_name LockableDoor extends Node2D

@export var arrival_coordinates: Vector2i:
	set(value):
		arrival_coordinates = value
		
		if not is_inside_tree():
			await ready
		_arrival_icon.position = value

@export var is_locked: bool:
	set(value):
		is_locked = value
		
		if not is_inside_tree():
			await ready
		_locked_interaction.is_active = is_locked

@onready var _arrival_icon: = $ArrivalCell as Sprite2D
@onready var _locked_interaction: = $LockedInteraction


func _ready() -> void:
	if not Engine.is_editor_hint():
		_arrival_icon.queue_free()
