## Defines the playable area of the game and where everything on it lies.
##
## The gameboard is defined, essentially, as a grid of [Vector2i] cells. Anything may be
## placed on one of these cells, so the gameboard determines where each cell is located. In this
## case, we are using a simple orthographic (square) projection.
## [br][br]The grid is contained within the playable [member boundaries] and its constituent cells.
extends Node

## Emitted whenever [member properties] is set. This is used in case a [Gamepiece] is added to the
## board before the board properties are ready.
signal properties_set

## Emitted whenever the [member pathfinder] state changes.
## This signal is emitted automatically in response to changed [GameboardLayer]s.
##
## Note: This signal is only emitted when the actual movement state of the Gameboard
## changes. [GameboardLayer]s may change their cells without actually changing the pathfinder's
## state (i.e. a visual update only), in which case this signal is not emitted.
signal pathfinder_changed(added_cells: Array[Vector2i], removed_cells: Array[Vector2i])

## An invalid cell is not part of the gameboard. Note that this requires positive
## [member boundaries].
const INVALID_CELL: = Vector2i(-1, -1)

const INVALID_INDEX: = -1

## Determines the [member GameboardProperties.extents] of the Gameboard, among other details.
var properties: GameboardProperties = null:
	set(value):
		if value != properties:
			properties = value
			properties_set.emit()

## A reference to the Pathfinder for the current playable area.
@onready var pathfinder: Pathfinder = Pathfinder.new()


## Convert cell coordinates to pixel coordinates.
func cell_to_pixel(cell_coordinates: Vector2i) -> Vector2:
	return Vector2(cell_coordinates * properties.cell_size) + properties.half_cell_size


## Convert pixel coordinates to cell coordinates.
func pixel_to_cell(pixel_coordinates: Vector2) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(
		floori(pixel_coordinates.x / properties.cell_size.x),
		floori(pixel_coordinates.y / properties.cell_size.y)
	)


func get_cell_under_node(node: Node2D) -> Vector2i:
	return pixel_to_cell(node.global_position/node.global_scale)


## Convert cell coordinates to an index unique to those coordinates.
## [br][br][b]Note:[/b] cell coordinates outside the [member extents] will return
## [constant INVALID_INDEX].
func cell_to_index(cell_coordinates: Vector2i) -> int:
	if properties.extents.has_point(cell_coordinates):
		# Negative coordinates can throw off index generation, so offset the boundary so that it's
		# top left corner is always considered Vector2i.ZERO and index 0.
		return (cell_coordinates.x-properties.extents.position.x) \
			+ (cell_coordinates.y-properties.extents.position.y)*properties.extents.size.x
	return INVALID_INDEX


## Convert a unique index to cell coordinates.
## [br][br][b]Note:[/b] indices outside the gameboard [member GameboardProperties.extents] will
## return [constant INVALID_CELL].
func index_to_cell(index: int) -> Vector2i:
	@warning_ignore("integer_division")
	var cell: = Vector2i(
		index % properties.extents.size.x + properties.extents.position.x,
		index / properties.extents.size.x + properties.extents.position.y
	)

	if properties.extents.has_point(cell):
		return cell
	return INVALID_CELL


## Find a neighbouring cell, if it exists. Otherwise, returns [constant INVALID_CELL].
func get_adjacent_cell(cell: Vector2i, direction: int) -> Vector2i:
	var neighbour: Vector2i = cell + Directions.MAPPINGS.get(direction, Vector2i.ZERO)
	if properties.extents.has_point(neighbour):
		return neighbour
	return INVALID_CELL


## Find all cells adjacent to a given cell. Only existing cells will be included.
func get_adjacent_cells(cell: Vector2i) -> Array[Vector2i]:
	var neighbours: Array[Vector2i] = []
	for direction in Directions.Points.values():
		var neighbour = get_adjacent_cell(cell, direction)
		if not neighbour == INVALID_CELL and not neighbour == cell:
			neighbours.append(neighbour)

	return neighbours


## The Gameboard's state (where [Gamepiece]'s may or may not move) is composed from a number of
## [GameboardLayer]s. These layers determine which cells are blocked or clear.
## The layers register themselves to the Gameboard in _ready.
func register_gameboard_layer(board_map: GameboardLayer) -> void:
	# We want to know whenever the board_map changes the gameboard state. This occurs when the map
	# is added or removed from the scene tree, or when its list of moveable cells changes.
	# Compare the changed cells with those already in the pathfinder. Any changes will cause the
	# Pathfinder to be updated.
	board_map.cells_changed.connect(
		func _on_gameboard_layer_cells_changed(cleared_cells: Array[Vector2i],
				blocked_cells: Array[Vector2i]):
		if board_map.name == "DoorGameboardLayer":
			print("Door layer ", cleared_cells, " ", blocked_cells)
		var added_cells: = _add_cells_to_pathfinder(cleared_cells)
		var removed_cells: = _remove_cells_from_pathfinder(blocked_cells)

		_connect_new_pathfinder_cells(added_cells)
		if not added_cells.is_empty() or not removed_cells.is_empty():
			pathfinder_changed.emit(added_cells.values(), removed_cells)
	)


# Add cells to the pathfinder, checking that there are no blocking tiles on any GameboardLayers.
# Returns a dictionary representing the cells that are actually added to the pathfinder (may differ
# from cleared_cells). Key = cell id (int, see cell_to_index), value = coordinate (Vector2i)
func _add_cells_to_pathfinder(cleared_cells: Array[Vector2i]) -> Dictionary[int, Vector2i]:
	var added_cells: Dictionary[int, Vector2i] = {}

	# Verify whether or not cleared/blocked cells will change the state of the pathfinder.
	# If there is no change in state, we will not pass along the cell to other systems and
	# the pathfinder won't actually be changed.
	for cell in cleared_cells:
		# Note that cleared cells need to have all layers checked for a blocking tile.
		if properties.extents.has_point(cell) and not pathfinder.has_cell(cell) \
				and _is_cell_clear(cell):
			var uid: = cell_to_index(cell)
			pathfinder.add_point(uid, cell)
			added_cells[uid] = cell

			# Flag the cell as disabled if it is occupied.
			if GamepieceRegistry.get_gamepiece(cell):
				pathfinder.set_point_disabled(uid)
	return added_cells


# Remove cells from the pathfinder so that Gamepieces can no longer move through them.
# Only one Gameboard layer needs to block a cell for it to be considered blocked.
# Returns an array of cell coordinates that have been blocked. Cells that were already not in the
# pathfinder will be excluded from this array.
func _remove_cells_from_pathfinder(blocked_cells: Array[Vector2i]) -> Array[Vector2i]:
	var removed_cells: Array[Vector2i] = []
	for cell in blocked_cells:
		# Only remove a cell that is already in the pathfinder. Also, we need to check that the cell
		# is not clear, since this method is also called when cells are removed from GameboardLayers
		# and other layers may still have this cell on their map.
		if pathfinder.has_cell(cell) and not _is_cell_clear(cell):
			pathfinder.remove_point(cell_to_index(cell))
			removed_cells.append(cell)
	return removed_cells


# Go through a list of cells added to the pathfinder (returned from _add_cells_to_pathfinder) and
# connect them to each other and existing pathfinder cells.
func _connect_new_pathfinder_cells(added_cells: Dictionary[int, Vector2i]) -> void:
	for uid in added_cells.keys():
		if pathfinder.has_point(uid):
			for neighbor in Gameboard.get_adjacent_cells(added_cells[uid]):
				var neighbor_id: = Gameboard.cell_to_index(neighbor)
				if pathfinder.has_point(neighbor_id):
					pathfinder.connect_points(uid, neighbor_id)


## Checks all [TileMapLayers] in the [constant GameboardLayer.GROUP] to see if the cell is clear
## (returns true) or blocked (returns false).
##
## A clear cell must fulfill two criteria:
##
## - Exists in at least one of the [GameboardLayer]s.[br]
## - None of the layers block movement at this cell, as defined by the
## [constant GameboardLayer.BLOCKED_CELL_DATA_LAYER] custom data layer (see
## [method TileData.get_custom_data])
func _is_cell_clear(coord: Vector2i) -> bool:
	# Check to make sure that cell exists.
	var cell_exists: = false

	for tilemap: GameboardLayer in get_tree().get_nodes_in_group(GameboardLayer.GROUP):
		if tilemap and coord in tilemap.get_used_cells():
			cell_exists = true
			if not tilemap.is_cell_clear(coord):
				return false

	# There is no terrain blocking cell movement. However we only want to allow movement if the cell
	# actually exists in one of the tilemap layers.
	return cell_exists
