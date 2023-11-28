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

@onready var _arrival_icon: = $GFX/ArrivalCell as Sprite2D
@onready var _locked_interaction: = $GFX/LockedInteraction


func _ready() -> void:
	if not Engine.is_editor_hint():
		_arrival_icon.queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_down"):
		is_locked = !is_locked
		print("Locked? ", is_locked)
		
		await get_tree().physics_frame
		await get_tree().physics_frame
		FieldEvents.terrain_changed.emit()
