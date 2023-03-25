## Contains blocking and non-blocking map objects.
##
## Blocking objects are static and are used by the [Gameboard] to prevent [Gamepiece] movement.
class_name ObstacleMap
extends TileMap

const BLOCKING_LAYER_KEY: = "BLOCKING"


func get_blocked_cells(limits: Rect2i) -> Array[Vector2i]:
	var blocked_cells: Array[Vector2i] = []
	
	var layer_index: = _get_blocking_layer_index()
	if layer_index >= 0:
		for cell in get_used_cells(layer_index):
			if limits.has_point(cell):
				blocked_cells.append(Vector2i(cell))
	
	return blocked_cells


func _get_blocking_layer_index() -> int:
	for i in get_layers_count():
		if get_layer_name(i).to_upper() == BLOCKING_LAYER_KEY:
			return i
	return -1
