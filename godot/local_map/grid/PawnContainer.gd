extends Node2D

func request_move(pawn, direction):
	return get_parent().request_move(pawn, direction)
