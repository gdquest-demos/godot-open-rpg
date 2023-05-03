extends Node

@onready var camera: = $Camera2D as Camera2D

## The physics layers which will be used to search for gamepiece obejcts.
## Please see the project properties for the specific physics layers. [b]All[/b] collision shapes
## matching the mask will be checked regardless of position in the scene tree.
@export_flags_2d_physics var gamepiece_mask: = 0

## The physics layers which will be used to search for terrain obejcts.
@export_flags_2d_physics var terrain_mask: = 0

@export var focus: Gamepiece = null:
	set = set_focus

@export var is_active: = false:
	set = set_is_active


func _ready() -> void:
	randomize()
	place_camera_at_focus()


func place_camera_at_focus() -> void:
	camera.reset_smoothing()


func set_focus(value: Gamepiece) -> void:
	if value == focus:
		return
	
	if focus:
		focus.camera_anchor.remote_path = ""
	
	focus = value
	
	if not is_inside_tree():
		await ready
	
	# Free up any lingering player controllers.
	for controller in get_tree().get_nodes_in_group(PlayerController.GROUP_NAME):
		controller.queue_free()
	
	
	if focus:
		focus.camera_anchor.remote_path = focus.camera_anchor.get_path_to(camera)
		
		var new_controller = PlayerController.new()
		new_controller.gamepiece_mask = gamepiece_mask
		new_controller.terrain_mask = terrain_mask
		
		focus.add_child(new_controller)
		new_controller.is_active = true


func set_is_active(value: bool) -> void:
	if not focus:
		value = false
	if value == is_active:
		return
	
	is_active = value
	
	if not is_inside_tree():
		await ready
	
	for controller in get_tree().get_nodes_in_group(PlayerController.GROUP_NAME):
		(controller as PlayerController).is_active = is_active
