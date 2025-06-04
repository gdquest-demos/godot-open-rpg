## A wrapper for [AStar2D] that allows working with [Vector2i] coordinates.
##
## Additionally provides utility methods for easily dealing with cell availability and passability.
class_name Pathfinder
extends AStar2D


func _init() -> void:
	# Disable/re-enable occupied cells whenever a gamepiece moves.
	GamepieceRegistry.gamepiece_moved.connect(
		func _on_gamepiece_moved(_gp: Gamepiece, new_cell: Vector2i, old_cell: Vector2i) -> void:
			var new_cell_id: = Gameboard.cell_to_index(new_cell)
			if has_point(new_cell_id):
				set_point_disabled(new_cell_id, true)
			
			var old_cell_id: = Gameboard.cell_to_index(old_cell)
			if has_point(old_cell_id):
				set_point_disabled(old_cell_id, false)
	)


## Returns true if the coordinate is found in the Pathfinder.
func has_cell(coord: Vector2i) -> bool:
	return has_point(Gameboard.cell_to_index(coord))


## Returns true if the coordinate is found in the Pathfinder and the cell is unoccupied.
func can_move_to(coord: Vector2i) -> bool:
	var uid: = Gameboard.cell_to_index(coord)
	return has_point(uid) and not is_point_disabled(uid)


## Find a path between two cells. Returns an empty array if no path is available.
## If allow_blocked_source or allow_blocked_target are false, the pathinder wlil fail if a gamepiece
## occupies the source or target cells, respectively.
func get_path_to_cell(source_coord: Vector2i, target_coord: Vector2i,
		allow_disabled_source: = true, allow_disabled_target: = false) -> Array[Vector2i]:
	# Store the return value in a variable.
	var move_path: Array[Vector2i] = []
	
	# Find the source/target IDs and keep track of whether or not the cells are occupied.
	var source_id: = Gameboard.cell_to_index(source_coord)
	var target_id: = Gameboard.cell_to_index(target_coord)
	
	if has_point(source_id) and has_point(target_id):
		# Check to see if we want to un-disable the source/target cells.
		var is_source_disabled: = is_point_disabled(source_id)
		var is_target_disabled: = is_point_disabled(target_id)
		if allow_disabled_source:
			set_point_disabled(source_id, false)
		if allow_disabled_target:
			set_point_disabled(target_id, false)
		
		for path_coord: Vector2i in get_point_path(source_id, target_id):
			if path_coord != source_coord: # Don't include the source as the first path element.
				move_path.append(path_coord)
		
		# If the source/target cells had originally been disabled, re-disable them here.
		if allow_disabled_source:
			set_point_disabled(source_id, is_source_disabled)
		if allow_disabled_target:
			set_point_disabled(target_id, is_target_disabled)
		
		
		#set_point_disabled(source_id, is_source_disabled)
	
	return move_path


## Find a path to a cell adjacent to the target coordinate.
## Returns an empty path if there are no pathable adjacent cells.
func get_path_cells_to_adjacent_cell(source_coord: Vector2i,
		target_coord: Vector2i) -> Array[Vector2i]:
	var shortest_path: Array[Vector2i] = []
	var shortest_path_length: = INF
	
	for cell in Gameboard.get_adjacent_cells(target_coord):
		var cell_path: = get_path_to_cell(source_coord, cell)
		
		if not cell_path.is_empty() and cell_path.size() < shortest_path_length:
			shortest_path_length = cell_path.size()
			shortest_path = cell_path
	
	return shortest_path


# Format the pathfinder so that it may be easily debugged with print.
func _to_string() -> String:
	var value: = "\nPathfinder:"
	for index in get_point_ids():
		var cell_header: = "\n%s - Id: %d;" % [str(Gameboard.index_to_cell(index)), index]
		
		var is_disabled: = "\t\t\t"
		if is_point_disabled(index):
			is_disabled = " (disabled)\t"
			
		value += (cell_header + is_disabled + "Linked to: %s" % get_point_connections(index))
	return value + "\n"
