@tool
@icon("res://assets/editor/icons/IconGamepieceController.svg")
class_name GamepieceController extends Node2D

# The controller operates on its direct parent, which must be a gamepiece object.
var _gamepiece: Gamepiece

# Keep track of a move path. The controller will check that the path is clear each time the 
# gamepiece needs to continue on to the next cell.
var move_path: Array[Vector2i] = []:
	set = move_along_path
var _current_waypoint: Vector2i

## An active controller will receive input events and process at idle and physics frames. An
## inactive controller will not.
var is_active: = false:
	set(value):
		is_active = value
		
		set_process(is_active)
		set_physics_process(is_active)
		set_process_input(is_active)
		set_process_unhandled_input(is_active)


func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	
	if not Engine.is_editor_hint():
		is_active = true
		
		_gamepiece.arriving.connect(_on_gamepiece_arriving)
		_gamepiece.arrived.connect(_on_gamepiece_arrived)
		
		#FieldEvents.input_paused.connect(_on_input_paused)


func _process(_delta: float) -> void:
	if _gamepiece.is_moving():
		return
	
	var input_direction: = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_direction:
		if not _gamepiece.is_moving():
			var source_cell: = GamepieceRegistry.get_cell(_gamepiece)
			var target_cell: = Vector2i.ZERO
			
			# Unless using 8-direction movement, one movement axis must be preferred. 
			#	Default to the x-axis.
			if not is_zero_approx(input_direction.x):
				input_direction = Vector2(input_direction.x, 0)
			else:
				input_direction = Vector2(0, input_direction.y)
			target_cell = Gameboard.pixel_to_cell(_gamepiece.position) + Vector2i(input_direction)
			
			# Try to get a path to destination (will fail if cell is occupied)
			var new_move_path: = Gameboard.pathfinder.get_path_to_cell(source_cell, target_cell)
			
			# Path is invalid. Bump animation?
			if new_move_path.size() <= 1:
				pass
			
			else:
				GamepieceRegistry.move_gamepiece(_gamepiece, target_cell)
				_gamepiece.move_to(Gameboard.cell_to_pixel(target_cell))
			print(new_move_path)
			#print(Gameboard.pathfinder.get_path_to_cell())
			# If path is valid, move.


#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_released("select"):
		#var source_cell: = GamepieceRegistry.get_cell(_gamepiece)
		#var clicked_cell: = Gameboard.pixel_to_cell(get_global_mouse_position()/global_scale)
		#
		#var new_move_path: = Gameboard.pathfinder.get_path_to_cell(source_cell, clicked_cell)
		#if not new_move_path.is_empty():
			##print("Found path. ", move_path)
			#move_path = new_move_path
		#
		#else:
			#var adjacent_path: = Gameboard.pathfinder.get_path_cells_to_adjacent_cell(source_cell, clicked_cell)
			#if adjacent_path:
				##print("No path, use adjacent instead", adjacent_path)
				#move_path = adjacent_path
			#
			#else:
				#print("No path found.")


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _gamepiece:
		warnings.append("This object must be a child of a gamepiece!")
	
	return warnings


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		_gamepiece = get_parent() as Gamepiece
		update_configuration_warnings()


func move_along_path(value: Array[Vector2i]) -> void:
	move_path = value
	if move_path.size() >= 1 and Gameboard.pathfinder.can_move_to(move_path[0]):
		_current_waypoint = move_path.pop_front()
		_gamepiece.move_to(Gameboard.cell_to_pixel(_current_waypoint))
		
		GamepieceRegistry.move_gamepiece(_gamepiece, _current_waypoint)
	
	else:
		move_path.clear()


# The controller's gamepiece will finish travelling this frame unless it is extended. When following
# a path, the gamepiece will want to travel to the next waypoint.
# excess_distance covers cases where the gamepiece will move past the current waypoint and prevents
# stuttering for a single frame (or slower-than-expected movement for *very* fast gamepieces).
func _on_gamepiece_arriving(excess_distance: float) -> void:
	if not move_path.is_empty() and is_active:
		# Fast gamepieces could jump several waypoints at once, so check to see which waypoint is
		# next in line. 
		while not move_path.is_empty() and excess_distance > 0:
			if not Gameboard.pathfinder.can_move_to(move_path[0]):
				print("Can't move to ", move_path[0])
				return
			
			_current_waypoint = move_path.pop_front()
			var destination = Gameboard.cell_to_pixel(_current_waypoint)
			var distance_to_waypoint: = \
				_gamepiece.position.distance_to(destination)
			
			_gamepiece.move_to(destination)
			GamepieceRegistry.move_gamepiece(_gamepiece, _current_waypoint)
			
			excess_distance -= distance_to_waypoint


func _on_gamepiece_arrived() -> void:
	move_path.clear()
