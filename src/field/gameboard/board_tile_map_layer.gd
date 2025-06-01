## A variation of [TileMapLayer] that is used to create the [Gameboard].
##
## Comes setup with a few tools used by designers to setup maps, specifying which cells may be
## moved to or from.
class_name BoardTileMapLayer extends TileMapLayer

## The group name of all [BoardTileMapLayer] that will be checked for blocked/walkable cells.
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

# A "dirty" TileMapLayer needs to have its _clear_cells dictionary reevaluated. This occurs whenever
# a change happens in the TileMapLayer and can occur multiple times per frame, so the dirty flag
# allows us to rebuild the _clear_cells dictionary at most once per frame.
var _is_dirty: = false


func _ready() -> void:
	add_to_group(GROUP)
	
	# Flag the layer as "dirty", meaning that the _clear_cells dictionary needs to be reevaluated.
	# This may happen multiple times per frame,
	#changed.connect(
		#func _on_tilemaplayer_changed() -> void:
			#print("Changed!")
			#_is_dirty = true
			#
			## Defer the call to end of frame so that multiple calls will occur at the same time.
			## Only one will ever be processed, since the _is_dirty flag will be reset once the cell
			## list has been rebuilt.
			#_rebuild_clear_cell_list.call_deferred()
	#)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		set_cell(Vector2i(3, 1)) # Clear the cell
		set_cell(Vector2i(2, 0), 0, Vector2i(0, 0), 0) # Clear the cell
	
	elif event.is_action_released("ui_cancel"):
		queue_free()


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
		print("%s Updating cells. Added: %s, Removed: %s" % [name, added_cells, removed_cells],
			" Forced cleanup: ", forced_cleanup)
		Gameboard.cells_changed.emit(added_cells, removed_cells)


func is_cell_clear(cell: Vector2i) -> bool:
	return clear_cells.get(cell, false) as bool


#func _rebuild_clear_cell_list() -> void:
	## We want to compare the new cell list with the old. If they're the same, we won't tell other
	## systems about the updated dictionary.
	#var new_clear_cell_list: Dictionary[Vector2i, bool] = {}
	#
	## Don't rebuild the list if the tilemap isn't flagged as "dirty". This prevents the list from
	## being rebuilt unnecessarily, such as if this method is called multiple times per frame.
	#if not _is_dirty:
		#print("Called rebuild cell list. Not dirty.")
		#return
	#
	## Reset the clear cell list and check to make sure that the blocked cell data layer exists.
	#clear_cells.clear()
	#if not tile_set or not tile_set.has_custom_data_layer_by_name(BLOCKED_CELL_DATA_LAYER):
		#print("Called rebuild cell list. No tileset/data layer.")
		#return
	#
	## Loop through all cells in the TileMapLayer, adding non-blocked (i.e. cleared) cells to the
	## _clear_cells dictionary.
	#for coord in get_used_cells():
		#var tile_data: = get_cell_tile_data(coord)
		#if tile_data:
			#var is_cell_blocked: = tile_data.get_custom_data(BLOCKED_CELL_DATA_LAYER) as bool
			#if not is_cell_blocked:
				#new_clear_cell_list[coord] = not is_cell_blocked
	#
	## Reset the dirty flag so that this method won't be called again this frame.
	#print("Rebuilt clear cell list. ")
	#_is_dirty = false
	#
	## Finally, compare the new clear cell list with the old. If they're different, we want to let
	## other systems know that the gameboard has changed.
	#var added_cells: = new_clear_cell_list.keys().filter(
		#func(cell: Vector2i) -> bool: return cell not in clear_cells
	#)
	#var removed_cells: = clear_cells.keys().filter(
		#func(cell: Vector2i) -> bool: return cell not in new_clear_cell_list
	#)
	#if not added_cells.is_empty() or not removed_cells.is_empty():
		#clear_cells = new_clear_cell_list
		#print("Changed cells! ", clear_cells)
		#Gameboard.cells_changed.emit(added_cells, removed_cells)
