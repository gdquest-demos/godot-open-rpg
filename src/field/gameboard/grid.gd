## Defines properties needed to place objects on the gameboard.
##
## Responsible for laying out the playable boundaries and its constituent cells. Also handles all
## conversion methods needed to place objects on the grid and move them about.
class_name Grid
extends Resource

const INVALID_CELL: = Vector2i(-1, -1)
const INVALID_INDEX: = -1

const _DIRECTION_MAPPINGS: = {
	Directions.Points.N: Vector2i.UP,
	Directions.Points.E: Vector2i.RIGHT,
	Directions.Points.S: Vector2i.DOWN,
	Directions.Points.W: Vector2i.LEFT,
}

@export var boundaries: = Rect2i(0, 0, 10, 10):
	set(value):
		boundaries = value
		
		# Clamp the map boundaries to a positive position and map size greater than 0.
		boundaries.position.x = maxi(boundaries.position.x, 0)
		boundaries.position.y = maxi(boundaries.position.y, 0)
		boundaries.size.x = maxi(boundaries.size.x, 1)
		boundaries.size.y = maxi(boundaries.size.y, 1)

@export var cell_size: = Vector2i(16, 16):
	set(value):
		cell_size = value
		_half_cell_size = cell_size/2

var _half_cell_size: = cell_size / 2


func cell_to_pixel(cell_coordinates: Vector2i) -> Vector2i:
	return cell_coordinates * cell_size + _half_cell_size


func pixel_to_cell(pixel_coordinates: Vector2) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(
		floori(pixel_coordinates.x / cell_size.x), 
		floori(pixel_coordinates.y / cell_size.y)
	)


func cell_to_index(cell_coordinates: Vector2i) -> int:
	return cell_coordinates.x + cell_coordinates.y*boundaries.size.x


func index_to_cell(index: int) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(
		index % boundaries.size.x,
		index / boundaries.size.x
	)


func get_adjacent_cell(cell: Vector2i, direction: int) -> Vector2i:
	return cell + _DIRECTION_MAPPINGS.get(direction, Vector2i.ZERO)


func get_adjacent_cells(cell: Vector2i) -> Array[Vector2i]:
	var neighbours: Array[Vector2i] = []
	for direction in Directions.Points.values():
		var neighbour = get_adjacent_cell(cell, direction)
		if not neighbour == cell:
			neighbours.append(neighbour)
	
	return neighbours
