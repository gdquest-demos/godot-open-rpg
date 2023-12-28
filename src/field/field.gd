extends Node2D

const PLAYER_CONTROLLER: = preload("res://src/field/gamepieces/controllers/PlayerController.tscn")

## The physics layers which will be used to search for gamepiece objects.
## Please see the project properties for the specific physics layers. [b]All[/b] collision shapes
## matching the mask will be checked regardless of position in the scene tree.
@export_flags_2d_physics var gamepiece_mask: = 0

## The physics layers which will be used to search for terrain obejcts.
@export_flags_2d_physics var terrain_mask: = 0

@export var focused_game_piece: Gamepiece = null:
	set = set_focused_game_piece

@export var gameboard: Gameboard


func _ready() -> void:
	randomize()
	
	assert(gameboard)
	Camera.scale = scale
	Camera.gameboard = gameboard
	Camera.make_current()
	
	Camera.reset_position()


func set_focused_game_piece(value: Gamepiece) -> void:
	if value == focused_game_piece:
		return

	focused_game_piece = value
	
	if not is_inside_tree():
		await ready
	
	Camera.gamepiece = focused_game_piece
	
	# Free up any lingering controller(s).
	for controller in get_tree().get_nodes_in_group(PlayerController.GROUP_NAME):
		controller.queue_free()
	
	if focused_game_piece:
		var new_controller = PLAYER_CONTROLLER.instantiate()
		new_controller.gamepiece_mask = gamepiece_mask
		new_controller.terrain_mask = terrain_mask
		
		focused_game_piece.add_child(new_controller)
		new_controller.is_active = true
