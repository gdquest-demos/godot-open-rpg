extends TileMap

enum CELL_TYPES { EMPTY = -1, ACTOR, OBSTACLE, OBJECT }

onready var pawns = $Pawns

func _ready():
	for child in pawns.get_children():
		if child is PawnFollower:
			continue
		child.position = request_move(child, Vector2(0, 0))
		set_cellv(world_to_map(child.position), child.type)

func get_cell_pawn(coordinates):
	for node in pawns.get_children():
		if world_to_map(node.position) == coordinates:
			return(node)

func request_move(pawn, direction):
	var cell_start = world_to_map(pawn.position)
	var cell_target = cell_start + direction
	
	var cell_target_type = get_cellv(cell_target)
	if cell_target_type == EMPTY or cell_target_type == OBJECT:
		return update_pawn_position(pawn, cell_start, cell_target)

func update_pawn_position(pawn, cell_start, cell_target):
	set_cellv(cell_target, pawn.type)
	set_cellv(cell_start, CELL_TYPES.EMPTY)
	return map_to_world(cell_target) + cell_size / 2
