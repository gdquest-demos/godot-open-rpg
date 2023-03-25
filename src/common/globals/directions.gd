class_name Directions
extends RefCounted

enum Points { NW, N, NE, E, SE, S, SW, W }


static func angle_to_direction(angle: float) -> Points:
	if angle <= -PI/4 and angle > -3*PI/4:
		return Points.N
	elif angle <= PI/4 and angle > -PI/4:
		return Points.E
	elif angle <= 3*PI/4 and angle > PI/4:
		return Points.S
	
	return Points.W
