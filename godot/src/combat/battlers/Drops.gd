# Holds a list of items to reward the player with upon e.g. 
# killing a monster
extends Node
class_name Drops

export var experience: int = 0


func get_drops() -> Array:
	return get_children()
