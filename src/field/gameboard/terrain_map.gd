## Contains all walkable cells in the field map.
##
## [method get_walkable_cells] is used by the [Gameboard] to indicate which cells may be traversed.
class_name TerrainMap
extends TileMap


## Find an array of all unique non-empty cells (within the limits) across all layers.
func get_walkable_cells(limits: Rect2i) -> Array[Vector2i]:
	# Only the dictionary keys of unique_cells are used since they're guaranteed to be unique.
	var unique_cells: = {}
	
	# Look through all terrain layers for non-empty cells. If the coordinates fit within the limits
	# add them to the cell list.
	for layer_i in get_layers_count():
		for cell in get_used_cells(layer_i):
			if limits.has_point(cell):
				unique_cells[cell] = 0
	
	var cells: Array[Vector2i] = []
	for cell in unique_cells.keys():
		cells.append(Vector2i(cell))
	
	return cells
