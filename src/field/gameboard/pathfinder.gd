## A wrapper for [AStar2D] that allows working with [Vector2i] coordinates.
##
## Additionally provides utility methods for easily dealing with cell availability and passability.
class_name Pathfinder
extends AStar2D


## Returns true if the coordinate is found in the Pathfinder.
func has_cell(coord: Vector2i) -> bool:
	return has_point(Gameboard.cell_to_index(coord))


## Returns true if the coordinate is found in the Pathfinder and the cell is unoccupied.
func can_move_to(coord: Vector2i) -> bool:
	var uid: = Gameboard.cell_to_index(coord)
	return has_point(uid) and not is_point_disabled(uid)


## Find a path between two cells. Returns an empty array if no path is available.
func get_path_to_cell(source_coord: Vector2i, target_coord: Vector2i) -> Array[Vector2i]:
	var move_path: Array[Vector2i] = []
	
	var source_id: = Gameboard.cell_to_index(source_coord)
	var target_id: = Gameboard.cell_to_index(target_coord)
	if has_point(source_id) and has_point(target_id):
		for path_coord: Vector2i in get_point_path(source_id, target_id):
			if path_coord != source_coord: # Don't include the source as the first path element.
				move_path.append(path_coord)
	
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


func _to_string() -> String:
	var value: = "\nPathfinder:"
	for index in get_point_ids():
		value += "\n%s - Id: %d; Linked to: %s" % [str(Gameboard.index_to_cell(index)), index, 
			get_point_connections(index)]
	return value + "\n"
