## A variation of [TileMapLayer] that is used to create the [Gameboard].
##
## Comes setup with a few tools used by designers to setup maps, specifying which cells may be
## moved to or from. Multiple GameboardLayers may exist simultaneously to allow developers to
## affect the gameboard with more than one layer.
##[/br][/br] These collision layers may also dynamically change, with the changes being reflected
## by the gameboard and pathfinder.
class_name GameboardLayer extends TileMapLayer

## Emitted whenever the collision state of the tile map changes.
##[/br][/br] The GameboardLayer's tile map may change without changing which cells are blocked or
## are open for movement. In this case, the signal is not emitted. However, it is emitted whenever
## the map is added or removed from the game, in addition to when there is a change in blocked/clear
## cells.
signal cells_changed(added_cells: Array[Vector2i], removed_cells: Array[Vector2i])

## The group name of all [GameboardLayer] that will be checked for blocked/walkable cells.
const GROUP: = "GameboardTileMapLayers"

## The name of the "custom data layer" that determines whether or not a cell is blocked/walkable.
## The returned value will be a boolean reflecting if a cell is blocked or not. Fetches the value
## via [method TileData.get_custom_data].[/br][/br]
## If the data layer is not present in the [Tileset], then all cells in this [TileMapLayer] will,
## by default, block movement.
const BLOCKED_CELL_DATA_LAYER: = "IsCellBlocked"

# Keeps track of which cells are included in the tilemap layer. This is done in dictionary form to
# speed up cell lookups. The value is a boolean indicating whether or not the cell is clear, but
# the value is always true, since only clear cells are ever added to the dictionary.
var clear_cells: Dictionary[Vector2i, bool] = {}


func _ready() -> void:
	add_to_group(GROUP)
	Gameboard.register_gameboard_layer(self)


# See [method TileMapLayer._update_cells]; called whenever the cells change. This allows designers
# to change maps on the fly and the collision state of the pathfinder should update. The coords
# parameter lets us know which cells have changed. Also, the method is called as the TileMapLayer
# is added to the scene.
# Note that if forced_cleanup is true, the TileMapLayer is in a state where its tiles should not
# affect collision.
func _update_cells(coords: Array[Vector2i], forced_cleanup: bool) -> void:
	# First of all, check to make sure the the tilemap has a tileset and the specific custom data
	# layer that we need to specify whether or not a tile blocks movement.
	if not tile_set or not tile_set.has_custom_data_layer_by_name(BLOCKED_CELL_DATA_LAYER):
		print("Called rebuild cell list. No tileset/data layer.")
		return
	
	# Go through the specified coords, checking to see if any moveable cells (those that are NOT
	# blocked) have been added or removed.
	var added_cells: Array[Vector2i] = []
	var removed_cells: Array[Vector2i] = []
	if forced_cleanup:
		# This tilemap isn't being used anymore. Flag all of its cells as being removed.
		# Currently, toggline visibility back on won't re-add existing cells.
		removed_cells = clear_cells.keys()
		clear_cells.clear()
	
	if not forced_cleanup:
		for coord in coords:
			var tile_data: = get_cell_tile_data(coord)
			if tile_data:
				var is_cell_blocked: = tile_data.get_custom_data(BLOCKED_CELL_DATA_LAYER) as bool
				if not is_cell_blocked and not clear_cells.has(coord):
					clear_cells[coord] = true
					added_cells.append(coord)
					
					# Jump to the next coord. 
					continue
			
			# If the above conditions have not been met, the cell is blocked and it will be removed
			# from the clear list if it had been previously unblocked.
			if coord in clear_cells:
				clear_cells.erase(coord)
				removed_cells.append(coord)
	
	if not (added_cells.is_empty() and removed_cells.is_empty()):
		#print("%s Updating cells. Added: %s, Removed: %s" % [name, added_cells, removed_cells],
			#" Forced cleanup: ", forced_cleanup)
		cells_changed.emit(added_cells, removed_cells)


func is_cell_clear(cell: Vector2i) -> bool:
	return clear_cells.get(cell, false) as bool
