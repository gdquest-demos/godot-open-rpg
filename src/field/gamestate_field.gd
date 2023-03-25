extends GameState

@onready var gameboard: = $Gameboard as Gameboard
@onready var player: = $LocalPlayer as FieldPlayer


func enter(_data: Dictionary) -> void:
	player.controller.initialize(gameboard.grid, gameboard.gamepieces, gameboard.pathfinder)
	
	var gamepiece_directory: = gameboard.gamepieces as GamepieceDirectory
	player.set_focus(gamepiece_directory.get_by_uid("Player"))
	player.place_camera_at_focus()
	
	player.controller.is_active = true
