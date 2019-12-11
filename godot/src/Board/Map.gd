extends TileMap
# Visual representation of the Board/World.
#
# It only stores data, it doesn't do anything. It's used by PathFinder.


var tiles_dict : = {} setget, get_tiles_dict
var points : = [] setget , get_points
var obstacles : = [] setget , get_obstacles


func setup(extra_obstacles: Array) -> void:
	tiles_dict = {}
	points = []
	obstacles = []
	
	for eo in extra_obstacles:
		eo in get_points() and get_points().erase(eo)
		get_obstacles().push_back(eo)


func get_points() -> Array:
	if points.size() != 0:
		return points

	var out : = (
			get_used_cells_by_id(get_tiles_dict()["dirt"])
			+ get_used_cells_by_id(get_tiles_dict()["flowers"])
			+ get_used_cells_by_id(get_tiles_dict()["grass1"])
			+ get_used_cells_by_id(get_tiles_dict()["grass2"]))
	points = out
	return out


func get_obstacles() -> Array:
	if obstacles.size() != 0:
		return obstacles

	var out : = (
			get_used_cells_by_id(get_tiles_dict()["vegetation1"])
			+ get_used_cells_by_id(get_tiles_dict()["vegetation2"]))
	obstacles = out
	return out


func get_tiles_dict() -> Dictionary:
	if tiles_dict.size() != 0:
		return tiles_dict

	var out : = {}
	var ids : = tile_set.get_tiles_ids()
	for id in ids:
		out[tile_set.tile_get_name(id)] = id
	tiles_dict = out
	return out