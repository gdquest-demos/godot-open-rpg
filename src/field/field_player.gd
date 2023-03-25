## Stores session data and handles swapping controllable characters and their followers.
class_name FieldPlayer
extends Node

@onready var camera: = $Camera2D as Camera2D
@onready var controller: = $Controller as CharacterController

var focus: Gamepiece = null:
	set = set_focus


func set_focus(value: Gamepiece) -> void:
	if value == focus:
			return
	
	if focus:
		focus.camera_anchor.remote_path = ""
	
	focus = value
	
	var was_controller_active: = controller.is_active
	controller.is_active = false
	
	controller.focus = focus
	
	if focus:
		focus.camera_anchor.remote_path = focus.camera_anchor.get_path_to(camera)
	
	controller.is_active = was_controller_active


func place_camera_at_focus() -> void:
	camera.reset_smoothing()
