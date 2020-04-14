extends Node2D
class_name PathFinder
# Sets up the AStar algorithm for calculating possible path results with `get_point_path(from, to)`

onready var map: TileMap = $Map
onready var rect: Rect2 = map.get_used_rect()

var possible_directions := [] setget , get_possible_directions

var _astar := AStar2D.new()


func setup(encounters: Array) -> void:
	var extra_obstacles := []
	for encounter in encounters:
		extra_obstacles.push_back(map.world_to_map(encounter.position))
	map.setup(extra_obstacles)

	rect = map.get_used_rect()
	_add_points()
	_connect_points()


# Returns the path found between `start` and `end`
func get_point_path(start: Vector2, end: Vector2) -> PoolVector2Array:
	var out := PoolVector2Array()
	var start_index := Utils.as_index(start, rect.size.x)
	var to_index := Utils.as_index(end, rect.size.x)
	if not end in map.obstacles and _astar.has_point(start_index) and _astar.has_point(to_index):
		for point in _astar.get_point_path(start_index, to_index):
			out.push_back(point)
	return out


# Returns a Vector2 Array of possible directions.
# The PathFinder defines the possible directions available for the player: South, West, North, East
# with the help of this getter function.
func get_possible_directions() -> Array:
	if possible_directions.size() != 0:
		return possible_directions

	var out := []
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x != 0 or y != 0:
				out.push_back(Vector2(x, y))
	possible_directions = out
	return possible_directions


func _add_points() -> void:
	for point in map.points:
		_astar.add_point(Utils.as_index(point, rect.size.x), point)


func _connect_points() -> void:
	for point in map.points:
		for point_neighbor in _get_neighbors(point):
			_astar.connect_points(
				Utils.as_index(point, rect.size.x), Utils.as_index(point_neighbor, rect.size.x)
			)


func _get_neighbors(point: Vector2) -> Array:
	var out := []
	for direction in get_possible_directions():
		var neighbor: Vector2 = point + direction
		if (
			Utils.is_inside(neighbor, rect)
			and not _astar.are_points_connected(
				Utils.as_index(point, rect.size.x), Utils.as_index(neighbor, rect.size.x)
			)
			and not neighbor in map.obstacles
		):
			out.push_back(neighbor)
	return out
