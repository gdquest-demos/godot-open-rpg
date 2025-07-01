## A wrapper for [AStar2D] that allows working with [Vector2i] coordinates.
##
## Additionally provides utility methods for easily dealing with cell availability and passability.
class_name Pathfinder
extends AStar2D

## When finding a path, we may want to ignore certain cells that are occupied by Gamepeices.
## These flags specify which disabled cells will still allow the path through.
##
## Ignore the occupant of the source cell when searching for a path via [method path_to_cell].
## This is especially useful when wanting to find a path for a gamepiece from their current cell.
const FLAG_ALLOW_SOURCE_OCCUPANT = 1 << 0
## Ignore the occupant of the target cell when searching for a path via [method path_to_cell].
const FLAG_ALLOW_TARGET_OCCUPANT = 1 << 1
## Ignore all gamepieces on the pathfinder cells when searching for a path via
## [method path_to_cell].
const FLAG_ALLOW_ALL_OCCUPANTS = 1 << 2


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

	GamepieceRegistry.gamepiece_freed.connect(
		func _on_gamepiece_free(_gp: Gamepiece, coord: Vector2i) -> void:
			var cell_id: = Gameboard.cell_to_index(coord)
			if has_point(cell_id):
				set_point_disabled(cell_id, false)
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
		occupancy_flags: int = 1) -> Array[Vector2i]:
	# Store the return value in a variable.
	var move_path: Array[Vector2i] = []

	# Find the source/target IDs and keep track of whether or not the cells are occupied.
	var source_id: = Gameboard.cell_to_index(source_coord)
	var target_id: = Gameboard.cell_to_index(target_coord)

	# The pathfinder has several flags to ignore cell occupancy. We'll need to track which occupants
	# are temporarily ignored and then re-disable their pathfinder points once a path is found.
	# Key is point id, value is whether or not the point is disabled.
	var ignored_points: Dictionary[int, bool] = {}
	if (occupancy_flags & FLAG_ALLOW_ALL_OCCUPANTS) != 0:
		for id in get_point_ids():
			if is_point_disabled(id):
				ignored_points[id] = true
				set_point_disabled(id, false)

	if has_point(source_id) and has_point(target_id):
		# Check to see if we want to un-disable the source/target cells.
		if (occupancy_flags & FLAG_ALLOW_SOURCE_OCCUPANT) != 0:
			ignored_points[source_id] = is_point_disabled(source_id)
			set_point_disabled(source_id, false)
		if (occupancy_flags & FLAG_ALLOW_TARGET_OCCUPANT) != 0:
			ignored_points[target_id] = is_point_disabled(target_id)
			set_point_disabled(target_id, false)

		for path_coord: Vector2i in get_point_path(source_id, target_id):
			if path_coord != source_coord: # Don't include the source as the first path element.
				move_path.append(path_coord)

		# Change any enabled cells back to their previous state.
		for id in ignored_points:
			set_point_disabled(id, ignored_points[id])

	return move_path


## Find a path to a cell adjacent to the target coordinate.
## Returns an empty path if there are no pathable adjacent cells.
func get_path_cells_to_adjacent_cell(source_coord: Vector2i,
		target_coord: Vector2i, occupancy_flags: int = 1) -> Array[Vector2i]:
	var shortest_path: Array[Vector2i] = []
	var shortest_path_length: = INF

	for cell in Gameboard.get_adjacent_cells(target_coord):
		var cell_path: = get_path_to_cell(source_coord, cell, occupancy_flags)
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
