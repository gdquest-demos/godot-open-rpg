## Manages the player party, including which characters are currently controlled.
class_name FieldPlayer
extends Node

## The physics layers which will be used to search for gamepiece obejcts.
## Please see the project properties for the specific physics layers. [b]All[/b] collision shapes
## matching the mask will be checked regardless of position in the scene tree.
var gamepiece_mask: = 0

## The physics layers which will be used to search for terrain obejcts.
var terrain_mask: = 0

@onready var camera: = $Camera2D as Camera2D

var focus: Gamepiece = null:
	set = set_focus

var is_active: = false:
	set = set_is_active


func initialize(gp_layer_mask: int, terrain_layer_mask: int) -> void:
	gamepiece_mask = gp_layer_mask
	terrain_mask = terrain_layer_mask


func place_camera_at_focus() -> void:
	camera.reset_smoothing()


func set_focus(value: Gamepiece) -> void:
	if value == focus:
		return
	
	if focus:
		focus.camera_anchor.remote_path = ""
	
	# Free up any lingering player controllers.
	for controller in get_tree().get_nodes_in_group(PlayerController.GROUP_NAME):
		controller.queue_free()
	
	focus = value
	
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
	
	for controller in get_tree().get_nodes_in_group(PlayerController.GROUP_NAME):
		controller.is_active = is_active
