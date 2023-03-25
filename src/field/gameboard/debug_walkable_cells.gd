## Draws blocked/non-pathable cells at runtime to help debug the gameboard & its gamepieces.
##
## Manually [method show] at runtime to debug gameboard occupancy.
extends TileMap

const LAYER_VOID: = 0
const LAYER_OBSTACLES: = 1
const LAYER_GPS: = 2

var _gamepieces: GamepieceDirectory = null


func initialize(grid: Grid, gp_dir: GamepieceDirectory, walkable_cells: Array[Vector2i],
		obstacle_cells: Array[Vector2i]) -> void:
	_gamepieces = gp_dir
	
	for cell_x in grid.boundaries.size.x:
		for cell_y in grid.boundaries.size.y:
			var coords: = Vector2i(cell_x, cell_y) + grid.boundaries.position
			if not coords in walkable_cells:
				set_cell(LAYER_VOID, coords, 0, Vector2i(2, 5))
			
			elif coords in obstacle_cells:
				set_cell(LAYER_OBSTACLES, coords, 0, Vector2i(2, 5))
	
	_on_gp_cell_changed()
	for gp in gp_dir.get_gamepieces():
		gp.cell_changed.connect(_on_gp_cell_changed)


func _on_gp_cell_changed(_old_cell: = Vector2i.ZERO, _new_cell: = Vector2i.ZERO) -> void:
	await get_tree().process_frame
	
	clear_layer(LAYER_GPS)
	for cell in _gamepieces.get_occupied_cells():
		set_cell(LAYER_GPS, cell, 0, Vector2i(2, 5))
