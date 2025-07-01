## A utility class converting between Godot angles (+'ve x axis is 0 rads) and cardinal points.
class_name Directions
extends RefCounted

## The cardinal points, in clockwise order starting from North.
enum Points { NORTH, EAST, SOUTH, WEST }

## The direction corresponding to a cardinal point as a [Vector2i] value. NORTH is Vector2i(0, -1), etc.
const MAPPINGS: = {
	Directions.Points.NORTH: Vector2i.UP,
	Directions.Points.EAST: Vector2i.RIGHT,
	Directions.Points.SOUTH: Vector2i.DOWN,
	Directions.Points.WEST: Vector2i.LEFT,
}


## Convert an angle, such as from [method Vector2.angle], to a [constant Points].
static func angle_to_direction(angle: float) -> Points:
	if angle <= -PI / 4.0 and angle > -3.0 * PI / 4.0:
		return Points.NORTH
	elif angle <= PI / 4.0 and angle > -PI / 4.0:
		return Points.EAST
	elif angle <= 3.0 * PI / 4.0 and angle > PI / 4.0:
		return Points.SOUTH

	return Points.WEST


static func vector_to_direction(vector: Vector2) -> Points:
	return angle_to_direction(vector.angle())
