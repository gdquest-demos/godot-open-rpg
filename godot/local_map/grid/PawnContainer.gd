extends Node2D

func _ready() -> void:
	for child in get_children():
		if "Follower" in child.name:
			child.position = $Leader.position

func request_move(pawn, direction):
	return get_parent().request_move(pawn, direction)
