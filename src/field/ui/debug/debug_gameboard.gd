extends TileMapLayer

@onready var _occupancy: TileMapLayer = $OccupancyGrid


func _ready() -> void:
	print("Connect debug grid")
	
	_occupancy.tile_set = tile_set
	
	Gameboard.cells_changed.connect(
		func _on_gameboard_cells_changed(added_cells: Array[Vector2i], 
				removed_cells: Array[Vector2i]) -> void:
			for cell in removed_cells:
				set_cell(cell) # Clear the cell
			for cell in added_cells:
				set_cell(cell, 0, Vector2i(0, 0), 0)
	)
	
	GamepieceRegistry.gamepiece_moved.connect(
		func _on_gp_moved(_gp: Gamepiece, new_cell: Vector2i, old_cell: Vector2i) -> void:
			print("Moved ", _gp.name, " from %s to %s." % [old_cell, new_cell])
			_occupancy.set_cell(old_cell)
			_occupancy.set_cell(new_cell, 0, Vector2i(1, 0), 0)
	)
