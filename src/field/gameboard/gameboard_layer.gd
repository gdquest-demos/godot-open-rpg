## A variation of [TileMapLayer] that is used to create the [Gameboard].
##
## Comes setup with a few tools used by designers to setup maps, specifying which cells may be
## moved to or from. Multiple GameboardLayers may exist simultaneously to allow developers to
## affect the gameboard with more than one layer.
##
## These collision layers may also dynamically change, with the changes being reflected
## by the gameboard and pathfinder.
class_name GameboardLayer extends TileMapLayer

## Emitted whenever the collision state of the tile map changes.
##
## The GameboardLayer's tile map may change without changing which cells are blocked or
## are open for movement. In this case, the signal is not emitted. However, it is emitted whenever
## the map is added or removed from the game, in addition to when there is a change in blocked/clear
## cells.
signal cells_changed(cleared_cells: Array[Vector2i], blocked_cells: Array[Vector2i])

## The group name of all [GameboardLayer] that will be checked for blocked/walkable cells.
const GROUP: = "GameboardTileMapLayers"

## The name of the "custom data layer" that determines whether or not a cell is blocked/walkable.
## The returned value will be a boolean reflecting if a cell is blocked or not. Fetches the value
## via [method TileData.get_custom_data].
##
## If the data layer is not present in the [Tileset], then all cells in this [TileMapLayer] will,
## by default, block movement.
const BLOCKED_CELL_DATA_LAYER: = "IsCellBlocked"

# A false value will cause is_cell_clear to always return true. This is used to flag when the
# TileMapLayers is being cleaned up an should no longer affect the pathfinder.
var _affects_collision: = true


func _ready() -> void:
	add_to_group(GROUP)
	Gameboard.register_gameboard_layer(self)

	tree_exiting.connect(
		func _on_tree_exiting() -> void:
			_affects_collision = false

			var blocked_cells: Array[Vector2i] = []
			cells_changed.emit(get_used_cells(), blocked_cells)
	)


## Returns true if the tile at coord exists and does not have a custom blocking data layer with a
## value set to true.
## Otherwise, returns false.
func is_cell_clear(coord: Vector2i) -> bool:
	if not _affects_collision:
		return true

	var tile_data: = get_cell_tile_data(coord)
	if tile_data:
		var is_cell_blocked: = tile_data.get_custom_data(BLOCKED_CELL_DATA_LAYER) as bool
		return not is_cell_blocked

	# If the above conditions have not been met, the cell is blocked.
	return false


# See [method TileMapLayer._update_cells]; called whenever the cells change. This allows designers
# to change maps on the fly and the collision state of the pathfinder should update. The coords
# parameter lets us know which cells have changed. Also, the method is called as the TileMapLayer
# is added to the scene.
# Note that if forced_cleanup is true, the TileMapLayer is in a state where its tiles should not
# affect collision. The conditions causing forced_cleanup are handled seperately through signals
# found in _ready().
func _update_cells(coords: Array[Vector2i], forced_cleanup: bool) -> void:
	# First of all, check to make sure the the tilemap has a tileset and the specific custom data
	# layer that we need to specify whether or not a tile blocks movement.
	if not tile_set or not tile_set.has_custom_data_layer_by_name(BLOCKED_CELL_DATA_LAYER):
		return

	# Go through the specified coords, checking to see if any moveable cells (those that are NOT
	# blocked) have been added or removed.
	var cleared_cells: Array[Vector2i] = []
	var blocked_cells: Array[Vector2i] = []

	if not forced_cleanup:
		for coord in coords:
			if is_cell_clear(coord):
				cleared_cells.append(coord)
			else:
				blocked_cells.append(coord)

	if not (cleared_cells.is_empty() and blocked_cells.is_empty()):
		cells_changed.emit(cleared_cells, blocked_cells)
