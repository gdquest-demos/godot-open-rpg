# Finds paths between cells accounting for terrain maps and [Gamepiece] positioning.
class_name Pathfinder
extends AStar2D

var _grid: Grid = null


# Only cells within the grid boundary will be considered.
func _init(pathable_cells: Array[Vector2i], grid: Grid) -> void:
	_grid = grid
	assert(_grid, "Pathfinder error: invalid grid objec passed to pathfinder constructor!")
	
	FieldEvents.gamepiece_initialized.connect(_on_gamepiece_initialized)
	
	_build_cell_list(pathable_cells)
	_connect_cells()


func get_cell_path(source_cell: Vector2i, target_cell: Vector2i) -> Array[Vector2i]:
	# Check to make sure that the source and target cells fall within the grid boundaries...
	if not _grid.boundaries.has_point(source_cell) or not _grid.boundaries.has_point(target_cell):
		return []
	
	# ...and that the source and target cells are registered with the pathfinder.
	var source_id: = _grid.cell_to_index(source_cell)
	var target_id: = _grid.cell_to_index(target_cell)
	if not has_point(source_id) or not has_point(target_id):
		return []
	
	# Disabled cells are those occupied by gamepieces, so assume that gamepiece at the start of the
	# path will be invovled in pathfinding.
	var disable_source: = is_point_disabled(source_id)
	set_point_disabled(source_id, false)
	
	var path_cells: Array[Vector2i] = []
	for cell in get_point_path(source_id, target_id):
		path_cells.append(Vector2i(cell))
	
	# Re-disable the start cell if it was blocked.
	set_point_disabled(source_id, disable_source)
	
	return path_cells


func get_cell_path_to_adjacent_cell(source_cell: Vector2i, 
		target_cell: Vector2i) -> Array[Vector2i]:
	var shortest_path: Array[Vector2i] = []
	var shortest_path_length: = INF
	
	for cell in _grid.get_adjacent_cells(target_cell):
		var cell_path: = get_cell_path(source_cell, cell)
		
		if not cell_path.is_empty() and cell_path.size() < shortest_path_length:
			shortest_path_length = cell_path.size()
			shortest_path = cell_path
	
	return shortest_path


func is_path_valid(cells: Array[Vector2i]) -> bool:
	for cell in cells:
		var cell_id: = _grid.cell_to_index(cell)
		if cell_id == Grid.INVALID_INDEX or not has_point(cell_id) or is_point_disabled(cell_id):
			return false
	
	return false


func has_cell(value: Vector2i) -> bool:
	var index: = _grid.cell_to_index(value)
	return has_point(index)


func get_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	
	for index in get_point_ids():
		var cell: = _grid.index_to_cell(index)
		cells.append(cell)
	
	return cells


func _build_cell_list(pathable_cells: Array[Vector2i]) -> void:
	for cell in pathable_cells:
		if not has_cell(cell) and _grid.boundaries.has_point(cell):
			var cell_id: = _grid.cell_to_index(cell)
			
			if cell_id != Grid.INVALID_INDEX:
				add_point(cell_id, cell)


func _connect_cells() -> void:
	for source_id in get_point_ids():
		var source_cell: = _grid.index_to_cell(source_id)
		
		var adjacent_cells: Array[Vector2i] = _grid.get_adjacent_cells(source_cell)
		for neighbour in adjacent_cells:
				var target_id: = _grid.cell_to_index(neighbour)
				
				if target_id != Grid.INVALID_INDEX and has_point(target_id):
					connect_points(source_id, target_id)


func _set_cell_blocked(cell: Vector2i, value: = true) -> void:
	var cell_id: = _grid.cell_to_index(cell)
	if cell_id != Grid.INVALID_INDEX:
		set_point_disabled(cell_id, value)


func _on_gamepiece_initialized(gamepiece: Gamepiece) -> void:
	gamepiece.blocks_movement_changed.connect(
		_on_gamepiece_blocks_movement_changed.bind(gamepiece))
	gamepiece.cell_changed.connect(_on_gamepiece_moved.bind(gamepiece))
	gamepiece.freed.connect(_on_gamepiece_freed.bind(gamepiece))
	
	if gamepiece.blocks_movement:
		_set_cell_blocked(gamepiece.cell, true)


func _on_gamepiece_blocks_movement_changed(gamepiece: Gamepiece) -> void:
	if gamepiece.blocks_movement:
		_set_cell_blocked(gamepiece.cell, true)
	else:
		_set_cell_blocked(gamepiece.cell, false)


func _on_gamepiece_moved(old_cell: Vector2i, gamepiece: Gamepiece) -> void:
	if gamepiece.blocks_movement:
		_set_cell_blocked(old_cell, false)
		_set_cell_blocked(gamepiece.cell, true)


func _on_gamepiece_freed(gamepiece: Gamepiece) -> void:
	if gamepiece.blocks_movement:
		_set_cell_blocked(gamepiece.cell)


func _to_string() -> String:
	var value: = "\nPathfinder:"
	for index in get_point_ids():
		value += "\n%s - Id: %d; Linked to: %s" % [str(_grid.index_to_cell(index)), index, 
			get_point_connections(index)]
	return value + "\n"
