@tool
extends UIPopup

@export var radius: = 32:
	set(value):
		radius = value
		
		if not is_inside_tree():
			await ready
		
		_collision_shape.shape.radius = radius

@onready var _area: = $Area2D as Area2D
@onready var _collision_shape: = $Area2D/CollisionShape2D as CollisionShape2D


func _ready() -> void:
	super._ready()
	
	if not Engine.is_editor_hint():
		FieldEvents.input_paused.connect(_on_input_paused)


func _on_area_entered(_entered_area: Area2D) -> void:
	_is_shown = true


func _on_area_exited(_exited_area: Area2D) -> void:
	_is_shown = false


# Be sure to hide input when the player is not able to do anything (e.g. cutscenes).
func _on_input_paused(paused: bool) -> void:
	_area.monitoring = !paused
