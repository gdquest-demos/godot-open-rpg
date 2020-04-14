# Map Grid. Responsible for collisions, telling pawns
# if they can move to a given cell
# Uses a Pathfinder to find and return the path to cells
extends TileMap

class_name GameBoard

enum CELL_TYPES { EMPTY = -1, ACTOR, OBSTACLE, OBJECT }

var pathfinder: Pathfinder = Pathfinder.new()
onready var pawns: YSort = $Pawns
onready var spawning_point = $SpawningPoint


func _ready():
	for pawn in pawns.get_children():
		pawn.position = request_move(pawn, Vector2(0, 0))
		pawn.initialize(self)
		set_cellv(world_to_map(pawn.position), pawn.type)
	pathfinder.initialize(self, [0, 1, 2])


func get_cell_pawn(coordinates: Vector2) -> Pawn:
	for pawn in pawns.get_children():
		if not world_to_map(pawn.position) == coordinates:
			continue
		return pawn
	return null


func request_move(pawn: PawnActor, direction: Vector2) -> Vector2:
	# Checks if the Pawn can move in the given direction
	# If so, updates the grid's content and returns 
	# the target cell's position in world coordinates
	# If not, returns Vector2(0, 0)
	var cell_start: Vector2 = world_to_map(pawn.position)
	var cell_target: Vector2 = cell_start + direction

	var cell_target_type: int = get_cellv(cell_target)
	if cell_target_type == CELL_TYPES.EMPTY or cell_target_type == CELL_TYPES.OBJECT:
		return update_pawn_position(pawn, cell_start, cell_target)
	return Vector2()


func find_path(start_world_position, end_world_position: Vector2) -> PoolVector3Array:
	# Returns an array of grid points that connect the start and end world position
	var end = world_to_map(end_world_position)
	if get_cellv(end) != CELL_TYPES.EMPTY:
		return PoolVector3Array()
	var start = world_to_map(start_world_position)
	return pathfinder.find_path(start, end)


func update_pawn_position(pawn: PawnActor, cell_start: Vector2, cell_target: Vector2) -> Vector2:
	set_cellv(cell_target, pawn.type)
	set_cellv(cell_start, CELL_TYPES.EMPTY)
	return map_to_world(cell_target) + cell_size / 2


func calculate_world_pos(grid_pos: Vector2) -> Vector2:
	return map_to_world(grid_pos) - cell_size / 2
