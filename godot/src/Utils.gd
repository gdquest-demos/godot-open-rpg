extends Node
# General utility library that can be used across multiple projects as an autoload script.

const ERR := 1e-6


func is_inside(point: Vector2, rect: Rect2) -> bool:
	return (
		point.x > rect.position.x
		and point.y > rect.position.y
		and point.x < rect.size.x
		and point.y < rect.size.y
	)


# Returns the coordinates as an integer, to convert 2D coordinates to a 1D array
func as_index(vector: Vector2, width: int) -> int:
	return int(vector.x + width * vector.y)


func to_vector2(from: Vector3) -> Vector2:
	return Vector2(from.x, from.y)


func to_vector3(from: Vector2) -> Vector3:
	return Vector3(from.x, from.y, 0)


func to_px(from: Vector2, cell_size: Vector2) -> Vector2:
	return from * cell_size
