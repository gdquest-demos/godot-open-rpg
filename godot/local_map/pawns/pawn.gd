extends Node2D

enum CELL_TYPES { ACTOR, OBSTACLE, OBJECT }
export(CELL_TYPES) var type = CELL_TYPES.ACTOR
# holds the formation
export var formation : PackedScene
