## A wrapper for [AStar2D] that allows working with [Vector2i] coordinates.
##
## Additionally provides utility methods for easily dealing with cell availability and passability.
class_name Pathfinder
extends AStar2D

# Requires the gameboard for board boundaries and cell <-> index conversion.
var _gameboard: Gameboard = null


# Only cells within the gameboard's boundary will be considered.
func _init(pathable_cells: Array[Vector2i], gameboard: Gameboard) -> void:
	_gameboard = gameboard
	assert(_gameboard, "Pathfinder::init error: invalid gameboard reference!")
	
	_build_cell_list(pathable_cells)
	_connect_cells()


## Find a path between two cells. Returns an empty array if no path is available.
func get_path_cells(source_cell: Vector2i, target_cell: Vector2i) -> Array[Vector2i]:
	# Check to make sure that the source and target cells fall within the gameboard boundaries...
	if not _gameboard.boundaries.has_point(source_cell) \
			or not _gameboard.boundaries.has_point(target_cell):
		return []
	
	# ...and that the source and target cells are registered with the pathfinder.
	var source_id: = _gameboard.cell_to_index(source_cell)
	var target_id: = _gameboard.cell_to_index(target_cell)
	if not has_point(source_id) or not has_point(target_id):
		return []
	
	# Disabled cells are usually occupied. Allow movement out of a disabled cell.
	var disable_source: = is_point_disabled(source_id)
	set_point_disabled(source_id, false)
	
	var path_cells: Array[Vector2i] = []
	for cell in get_point_path(source_id, target_id):
		path_cells.append(Vector2i(cell))
	
	# Re-disable the start cell if it was blocked.
	set_point_disabled(source_id, disable_source)
	
	return path_cells


## Get the shortest path to any cell adjacent to the specified target. Essentially allows moving
## [i]next[/i] to a target cell.
##
## Returns an empty array if there are no paths available.
func get_path_cells_to_adjacent_cell(source_cell: Vector2i, 
		target_cell: Vector2i) -> Array[Vector2i]:
	var shortest_path: Array[Vector2i] = []
	var shortest_path_length: = INF
	
	for cell in _gameboard.get_adjacent_cells(target_cell):
		var cell_path: = get_path_cells(source_cell, cell)
		
		if not cell_path.is_empty() and cell_path.size() < shortest_path_length:
			shortest_path_length = cell_path.size()
			shortest_path = cell_path
	
	return shortest_path


## Manually update whether or not a single cell is blocked.
## [br][br][b]Note:[/b] Blocked cells are usually occupied by a blocking [Gamepiece]. Cells that are 
## no longer pathable due to changes in terrain should be removed from the pathfinder entirely.
func block_cell(cell: Vector2i, value: = true) -> void:
	var cell_id: = _gameboard.cell_to_index(cell)
	if has_point(cell_id) and cell_id != Gameboard.INVALID_INDEX:
		set_point_disabled(cell_id, value)


## Update all blocked cells in the pathfinder in a single batch.
##
## [br][br][b]Note:[/b] Cells that were previously blocked but that are not included in the
## 'blocked' parameter will be unblocked.
func set_blocked_cells(blocked: Array[Vector2i]) -> void:
	for id in get_point_ids():
		var cell: = _gameboard.index_to_cell(id)
		block_cell(cell, cell in blocked)


## Returns a list of all cells that are currently blocked.
func get_blocked_cells() -> Array[Vector2i]:
	var blocked_cells: Array[Vector2i] = []
	for id in get_point_ids():
		if is_point_disabled(id):
			blocked_cells.append(_gameboard.index_to_cell(id))
	
	return blocked_cells


## Verify that a cell exists within the pathfinder. It may or may not be blocked.
func has_cell(value: Vector2i) -> bool:
	var index: = _gameboard.cell_to_index(value)
	return has_point(index)


## Get all cells that are registered with the pathfinder. Cells may or may not be blocked.
func get_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	
	for index in get_point_ids():
		var cell: = _gameboard.index_to_cell(index)
		cells.append(cell)
	
	return cells


func _build_cell_list(pathable_cells: Array[Vector2i]) -> void:
	for cell in pathable_cells:
		if not has_cell(cell) and _gameboard.boundaries.has_point(cell):
			var cell_id: = _gameboard.cell_to_index(cell)
			if cell_id != Gameboard.INVALID_INDEX:
				add_point(cell_id, cell)


func _connect_cells() -> void:
	for source_id in get_point_ids():
		var source_cell: = _gameboard.index_to_cell(source_id)
		
		var adjacent_cells: Array[Vector2i] = _gameboard.get_adjacent_cells(source_cell)
		for neighbour in adjacent_cells:
				var target_id: = _gameboard.cell_to_index(neighbour)
				
				if target_id != Gameboard.INVALID_INDEX and has_point(target_id):
					connect_points(source_id, target_id)


func _to_string() -> String:
	var value: = "\nPathfinder:"
	for index in get_point_ids():
		value += "\n%s - Id: %d; Linked to: %s" % [str(_gameboard.index_to_cell(index)), index, 
			get_point_connections(index)]
	return value + "\n"
