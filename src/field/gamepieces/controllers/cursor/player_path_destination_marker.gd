extends Sprite2D


func _ready() -> void:
	Player.player_path_set.connect(
		func(gamepiece: Gamepiece, destination_cell: Vector2i) -> void:
			if not gamepiece.arrived.is_connected(_on_gp_arrived):
				gamepiece.arrived.connect(_on_gp_arrived, CONNECT_ONE_SHOT)
			position = Gameboard.cell_to_pixel(destination_cell)
			show()
	)


func _on_gp_arrived() -> void:
	hide()
