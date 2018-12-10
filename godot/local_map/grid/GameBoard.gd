"""
Game board or Grid. Responsible for collisions, telling pawns
if they can move to a given cell
"""
extends TileMap

class_name GameBoard

enum CELL_TYPES { EMPTY = -1, ACTOR, OBSTACLE, OBJECT }

var pathfinder : Pathfinder = preload("res://local_map/grid/Pathfinder.gd").new()
onready var pawns : YSort = $Pawns
onready var spawning_point = $SpawningPoint

export var map_size : Vector2


func _ready():
	var occupied_cells : Array
	for child in pawns.get_children():
		child.position = request_move(child, Vector2(0, 0))
		set_cellv(world_to_map(child.position), child.type)

func get_cell_pawn(coordinates : Vector2) -> Pawn:
	for pawn in pawns.get_children():
		if not world_to_map(pawn.position) == coordinates:
			continue
		return pawn
	return null

func request_move(pawn : PawnActor, direction : Vector2) -> Vector2:
	"""
	Checks if the Pawn can move in the given direction
	If so, updates the grid's content and returns 
	the target cell's position in world coordinates
	If not, returns Vector2(0, 0)
	"""
	var cell_start : Vector2 = world_to_map(pawn.position)
	var cell_target : Vector2 = cell_start + direction
	
	var cell_target_type : int = get_cellv(cell_target)
	if cell_target_type == EMPTY or cell_target_type == OBJECT:
		return update_pawn_position(pawn, cell_start, cell_target)
	return Vector2()

func update_pawn_position(pawn : PawnActor, cell_start : Vector2, cell_target : Vector2) -> Vector2:
	set_cellv(cell_target, pawn.type)
	set_cellv(cell_start, CELL_TYPES.EMPTY)
	return map_to_world(cell_target) + cell_size / 2

func calculate_world_pos(grid_pos : Vector2) -> Vector2:
	return map_to_world(grid_pos) - cell_size / 2
