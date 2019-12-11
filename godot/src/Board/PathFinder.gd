extends Node2D
class_name PathFinder
# Sets up the AStar algorithm for calculating possible path results with `get_point_path(from, to)`


onready var map : TileMap = $Map
onready var rect : Rect2 = map.get_used_rect()

var possible_directions : = [] setget , get_possible_directions

var _algorithm : = AStar.new()


func setup(encounters: Array) -> void:
	var extra_obstacles : = []
	for encounter in encounters:
		extra_obstacles.push_back(map.world_to_map(encounter.position))
	map.setup(extra_obstacles)
	
	rect = map.get_used_rect()
	_add_points()
	_connect_points()


func get_point_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	var out : = PoolVector2Array()
	var from_idx : = Utils.to_idx(from, rect.size.x)
	var to_idx : = Utils.to_idx(to, rect.size.x)
	if (not to in map.obstacles
			and _algorithm.has_point(from_idx)
			and _algorithm.has_point(to_idx)):
		for point in _algorithm.get_point_path(from_idx, to_idx):
			out.push_back(Utils.to_vector2(point))
	return out

# The PathFinder defines the possible directions available for the player: South, West, North, East
# with the help of this getter function.
#
# Returns a Vector2 Array of possible directions.
func get_possible_directions() -> Array:
	if possible_directions.size() != 0:
		return possible_directions
	
	var out : = []
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x != 0 or y != 0:
				out.push_back(Vector2(x, y))
	possible_directions = out
	return possible_directions


func _add_points() -> void:
	for point in map.points:
		_algorithm.add_point(Utils.to_idx(point, rect.size.x), Utils.to_vector3(point))


func _connect_points() -> void:
	for point in map.points:
		for point_neighbor in _get_neighbors(point):
			_algorithm.connect_points(
					Utils.to_idx(point, rect.size.x),
					Utils.to_idx(point_neighbor, rect.size.x))


func _get_neighbors(point: Vector2) -> Array:
	var out : = []
	for direction in get_possible_directions():
		var neighbor : Vector2 = point + direction
		if (Utils.is_inside(neighbor, rect)
				and not _algorithm.are_points_connected(
						Utils.to_idx(point, rect.size.x), 
						Utils.to_idx(neighbor, rect.size.x))
				and not neighbor in map.obstacles):
			out.push_back(neighbor)
	return out