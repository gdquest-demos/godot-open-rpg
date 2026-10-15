## An autoload that provides easy access to the player's state, including both Combat and Field
## details.
## Reference to the player's party, inventory, and currently active character are found here.
## Additionally, game-wide player based signals are emitted from here.
extends Node

## Emitted when the player sets a movement path for their focused gamepiece.
## The destination is the last cell in the path.
@warning_ignore("unused_signal")
signal player_path_set(gamepiece: Gamepiece, destination_cell: Vector2i)

# The Gamepiece packed scene, used to create the player gamepiece.
const GAMEPIECE: = preload("res://src/field/gamepieces/gamepiece.tscn")

# The PlayerController packed scene, assigned to a newly created player gamepiece.
const CONTROLLER: = preload("res://src/field/gamepieces/controllers/player_controller.tscn")

## Tracks the cell that the player currently occupies, or will occupy when they are placed in the
## game world.
@export var cell: = Vector2i.ZERO

## The player's current [GamepieceAnimation], used when creating the player [Gamepiece].
@export var appearance: PackedScene:
	set(value):
		appearance = value

# The gamepeice that the player is currently controlling.
var _gamepiece: Gamepiece = null

@onready var _camera: Camera2D = $Camera2D


func create_gamepiece(parent: Node) -> void:
	if _gamepiece != null:
		_gamepiece.queue_free()
	
	_gamepiece = GAMEPIECE.instantiate()
	_gamepiece.name = "Player"
	_gamepiece.position = Gameboard.cell_to_pixel(cell)
	parent.add_child(_gamepiece, true)
	
	# Assign the player's avatar to the gamepiece.
	_gamepiece.animation_scene = appearance
	
	# Assign the player controller to the gamepiece.
	var player_controller: = CONTROLLER.instantiate()
	_gamepiece.add_child(player_controller)
	player_controller.is_active = true
	
	# Follow the player with the default camera.
	_gamepiece.animation_transform.remote_path = _gamepiece.animation_transform.get_path_to(_camera)
	_camera.make_current()
