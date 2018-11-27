extends Node2D

class_name Pawn

enum CELL_TYPES { ACTOR, OBSTACLE, OBJECT }
export(CELL_TYPES) var type = CELL_TYPES.ACTOR
export var formation : PackedScene
