@tool
## Defines the properties of the playable game map.
class_name GameboardProperties extends Resource

## Emitted whenever [member cell_size] changes.
signal cell_size_changed
## Emitted whenever [member extents] changes.
signal extents_changed

## An invalid index is not found on the gameboard. Note that this requires positive 
## [member extents].
const INVALID_INDEX: = -1

## The extents of the playable area. This property is intended for editor use and should not change
## during gameplay, as that would change how [Pathfinder] indices are calculated.
@export var extents: = Rect2i(0, 0, 10, 10):
	set(value):
		extents = value
		
		# Ensure that the boundary size is greater than 0.
		extents.size.x = maxi(extents.size.x, 1)
		extents.size.y = maxi(extents.size.y, 1)
		extents_changed.emit()

## The size of each grid cell. Usually analogous to a [member TileSet.tile_size] of a
## [GameboardLayer].
@export var cell_size: = Vector2i(16, 16):
	set(value):
		cell_size = value
		half_cell_size = cell_size/2
		cell_size_changed.emit()

var half_cell_size: = cell_size / 2.0


func _to_string() -> String:
	return "\n[GameboardProperties resource" + \
		"\nCell size: " + str(cell_size) + \
		"\nBoard extents: " + str(extents) + "]"
