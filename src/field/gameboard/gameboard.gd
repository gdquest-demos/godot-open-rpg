## Defines the playable area of the game and where everything on it lies.
##
## The gameboard is defined, essentially, as a grid of [Vector2i] cells. Anything may be
## placed on one of these cells, so the gameboard determines where each cell is located. In this 
## case, we are using a simple orthographic (square) projection.
## [br][br]The grid is contained within the playable [member boundaries] and its constituent cells.
class_name Gameboard
extends Resource

## An invalid cell is not part of the gameboard. Note that this requires positive 
## [member boundaries].
const INVALID_CELL: = Vector2i(-1, -1)

## An invalid index is not found on the gameboard. Note that this requires positive 
## [member boundaries].
const INVALID_INDEX: = -1

## Map cardinal [Directions] to a shift in coordinates.
const _DIRECTION_MAPPINGS: = {
	Directions.Points.N: Vector2i.UP,
	Directions.Points.E: Vector2i.RIGHT,
	Directions.Points.S: Vector2i.DOWN,
	Directions.Points.W: Vector2i.LEFT,
}

## The extents of the playable area.
## [br][br][b]Note:[/b] The boundaries must only include positive coordinates. Negative coordinates
## increase calculation complexity.
@export var boundaries: = Rect2i(0, 0, 10, 10):
	set(value):
		boundaries = value
		
		# Clamp the map boundaries to a positive position and map size greater than 0.
		boundaries.position.x = maxi(boundaries.position.x, 0)
		boundaries.position.y = maxi(boundaries.position.y, 0)
		boundaries.size.x = maxi(boundaries.size.x, 1)
		boundaries.size.y = maxi(boundaries.size.y, 1)

## The size of each grid cell. Usually - though not always - analogous to [TileSet]'s
## [member TileSet.tile_size].
@export var cell_size: = Vector2i(16, 16):
	set(value):
		cell_size = value
		_half_cell_size = cell_size/2

var _half_cell_size: = cell_size / 2


## Convert cell coordinates to pixel coordinates.
func cell_to_pixel(cell_coordinates: Vector2i) -> Vector2i:
	return cell_coordinates * cell_size + _half_cell_size


## Convert pixel coordinates to cell coordinates.
func pixel_to_cell(pixel_coordinates: Vector2) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(
		floori(pixel_coordinates.x / cell_size.x), 
		floori(pixel_coordinates.y / cell_size.y)
	)


## Convert cell coordinates to an index unique to those coordinates.
## [br][br][b]Note:[/b] cell coordinates outside the gameboard [member boundaries] will return
## [constant INVALID_INDEX].
func cell_to_index(cell_coordinates: Vector2i) -> int:
	if boundaries.has_point(cell_coordinates):
		return cell_coordinates.x + cell_coordinates.y*boundaries.size.x
	return INVALID_INDEX


## Convert a unique index to cell coordinates.
## [br][br][b]Note:[/b] indices outside the gameboard [member boundaries] will return
## [constant INVALID_CELL].
func index_to_cell(index: int) -> Vector2i:
	@warning_ignore("integer_division")
	var cell: = Vector2i(
		index % boundaries.size.x,
		index / boundaries.size.x
	)
	
	if boundaries.has_point(cell):
		return cell 
	return INVALID_CELL


## Find a neighbouring cell, if it exists. Otherwise, returns [constant INVALID_CELL].
func get_adjacent_cell(cell: Vector2i, direction: int) -> Vector2i:
	var neighbour: Vector2i = cell + _DIRECTION_MAPPINGS.get(direction, Vector2i.ZERO)
	if boundaries.has_point(neighbour):
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
