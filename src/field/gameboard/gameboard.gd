## Defines the playable area of the game and where everything on it lies.
##
## The gameboard is defined, essentially, as a grid of [Vector2i] cells. Anything may be
## placed on one of these cells, so the gameboard determines where each cell is located. In this 
## case, we are using a simple orthographic (square) projection.
## [br][br]The grid is contained within the playable [member boundaries] and its constituent cells.
extends Node

## Emitted whenever a [GameboardLayer]'s pathable cells change.
##[/br][/br]Note: A change on a single map layer may not reflect the full picture, since multiple
## tilemap layers may form the final gameboard.
@warning_ignore("unused_signal")
signal cells_changed(changed_cells: Array[Vector2i])

## An invalid cell is not part of the gameboard. Note that this requires positive 
## [member boundaries].
const INVALID_CELL: = Vector2i(-1, -1)

const INVALID_INDEX: = -1

## Determines the [member GameboardProperties.extents] of the Gameboard, among other details.
var properties: GameboardProperties = null


#func _ready() -> void:
	#print("GB ready")
	#assert(properties != null, "The Gameboard autoload must have a GameboardProperties resource" +
		#" set before its _ready function is called!")
	# Maybe have Pathfinder.build. Wait to build until after everything has been put together?
	# That is, if pathfinder is null, do nothing in the following callback.
	
	# There are two cases where we don't want the following signal to fire: when the TileMaps are
	# being created (since they're created one by one. Would be better to just poll each one
	# separately?) and when the tilemaps are freed, either at state change or before a new scene/map
	# comes in.
	
	# Maybe can remove clear_cells from GameboardLayers? Since it will all be cached in the
	# pathfinder by ID anyways? Still need to check each layer, however.
	
	# Could still have GameboardLayers register themselves with the Gameboard (in _ready).
	# Then could connect to their internal signal, rather than GB's own.
	# And the global signal would be, instead, when the pathfinder cells update.
	
	# The board state is composed from multiple GameboardLayers, which 
	#cells_changed.connect.call_deferred(
		#func _on_cells_changed(changed_cells: Array[Vector2i]):
			#print("Changed, responding from GB")
	#)
	


## The Gameboard's state (where [Gamepiece]'s may or may not move) is composed from a number of
## [GameboardLayer]s. These layers determine which cells are blocked or clear.
## The layers register themselves to the Gameboard in _ready.
func register_gameboard_layer(board_map: GameboardLayer) -> void:
	# We want to know whenever the board_map changes the gameboard state. This occurs when the map
	# is added or removed from the scene tree, or when its list of moveable cells changes.
	board_map.cells_changed.connect(
		func(one, two): print("%s added %s and removed %s" % [board_map.name, one, two])
	)


## Look through each [GameboardLayer] in the game, unifying their lists of which cells may be
## moved to.
func get_all_clear_cells() -> Array[Vector2i]:
	var clear_cells: Dictionary[Vector2i, bool] = {}
	
	for tilemap: GameboardLayer in get_tree().get_nodes_in_group(GameboardLayer.GROUP):
		if tilemap:
			clear_cells.merge(tilemap.clear_cells)
	
	return clear_cells.keys()


## Checks all [TileMapLayers] in the [constant GameboardLayer.GROUP] to see if the cell is clear
## (returns true) or blocked (returns false).
## [/br][/br]A clear cell must fulfill two criteria:
## [/br]- Exists in at least one of the [GameboardLayer]s.
## [/br]- None of the layers block movement at this cell, as defined by the
## [constant GameboardLayer.BLOCKED_CELL_DATA_LAYER] custom data layer
## (see [method TileData.get_custom_data])
func is_cell_clear(cell: Vector2i) -> bool:
	# Check to make sure that cell exists.
	var cell_exists: = false
	
	for tilemap: GameboardLayer in get_tree().get_nodes_in_group(GameboardLayer.GROUP):
		if tilemap and cell in tilemap.clear_cells:
			cell_exists = true
			if not tilemap.is_cell_clear(cell):
				return false
	
	# There is no terrain blocking cell movement. However we only want to allow movement if the cell
	# actually exists in one of the tilemap layers.
	return cell_exists


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
		index % properties.extents.size.x,
		index / properties.extents.size.x
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
