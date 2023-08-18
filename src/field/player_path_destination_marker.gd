extends Sprite2D

@export var gameboard: Gameboard


func _ready() -> void:
	FieldEvents.player_path_set.connect(
		func(gamepiece: Gamepiece, destination_cell: Vector2i) -> void:
			gamepiece.arrived.connect(hide, CONNECT_ONE_SHOT)
			position = gameboard.cell_to_pixel(destination_cell)
			show()
	)
