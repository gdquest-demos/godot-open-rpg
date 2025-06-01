## A utility class converting between Godot angles (+'ve x axis is 0 rads) and cardinal points.
class_name Directions
extends RefCounted

## Abbreviations for 8 cardinal points (i.e. NW = Northwest, or Vector2[-1, -1]).
enum Points { NW, N, NE, E, SE, S, SW, W }

## The [Vector2i] form of a given cardinal point. That is, North is Vector2i(0, -1), etc.
const MAPPINGS: = {
	#Directions.Points.NW: Vector2i(-1, -1),
	Directions.Points.N: Vector2i.UP,
	#Directions.Points.NE: Vector2i(1, -1),
	Directions.Points.E: Vector2i.RIGHT,
	#Directions.Points.SE: Vector2i(1, 1),
	Directions.Points.S: Vector2i.DOWN,
	#Directions.Points.SW: Vector2i(-1, 1),
	Directions.Points.W: Vector2i.LEFT,
}


## Convert an angle, such as from [method Vector2.angle], to a [constant Points].
static func angle_to_direction(angle: float) -> Points:
	if angle <= -PI/4 and angle > -3*PI/4:
		return Points.N
	elif angle <= PI/4 and angle > -PI/4:
		return Points.E
	elif angle <= 3*PI/4 and angle > PI/4:
		return Points.S
	
	return Points.W
