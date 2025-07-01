@tool
@icon("res://assets/editor/icons/IconGamepieceController.svg")
class_name GamepieceController extends Node2D

## Emitted whenever the gamepiece begins moving towards a new cell in its [member move_path].
signal waypoint_changed(waypoint: Vector2i)

## An active controller will receive inputs (player or otherwise). An inactive controller does
## nothing. This is useful, for example, when toggling of gamepiece movement during cutscenes.
var is_active: = false:
	set = set_is_active

## Keep track of a move path. The controller will check that the path is clear each time the 
## gamepiece needs to continue on to the next cell.
var move_path: Array[Vector2i] = []:
	set = move_along_path
var _current_waypoint: Vector2i:
	set(value):
		if value != _current_waypoint:
			_current_waypoint = value
			waypoint_changed.emit(_current_waypoint)

# The controller operates on its direct parent, which must be a gamepiece object.
var _gamepiece: Gamepiece


func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	
	if not Engine.is_editor_hint():
		is_active = true
		
		_gamepiece.arriving.connect(_on_gamepiece_arriving)
		_gamepiece.arrived.connect(_on_gamepiece_arrived)
		
		FieldEvents.input_paused.connect(
			func _on_input_paused(value: bool) -> void:
				is_active = !value
		)


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
	_move_to_next_waypoint()


## Set whether or not the controller may exert control over the gamepiece.
## There are a number of occasions (such as cutscenes or combat) where gamepieces are inactive.
func set_is_active(value: bool) -> void:
	is_active = value
	_move_to_next_waypoint() # Will only affect the gamepiece if is_active == true.


# Finds the [member move_path]'s waypoint using [method Array.pop_front] and begins moveing the
# gamepiece towards it.
# The method will do nothing if the controller is currently inactive.
# Returns the distance (in pixels) to the next waypoint.
func _move_to_next_waypoint() -> float:
	var distance_to_point: = 0.0
	
	if is_active:
		if move_path.size() >= 1 and Gameboard.pathfinder.can_move_to(move_path[0]):
			_current_waypoint = move_path.pop_front()
			var destination = Gameboard.cell_to_pixel(_current_waypoint)
			
			# Report how far away the waypoint is.
			distance_to_point = _gamepiece.position.distance_to(destination)
			_gamepiece.move_to(Gameboard.cell_to_pixel(_current_waypoint))
			
			GamepieceRegistry.move_gamepiece(_gamepiece, _current_waypoint)
	
	return distance_to_point


# The controller's gamepiece will finish travelling this frame unless it is extended. When following
# a path, the gamepiece will want to travel to the next waypoint.
# excess_distance covers cases where the gamepiece will move past the current waypoint and prevents
# stuttering for a single frame (or slower-than-expected movement for *very* fast gamepieces).
func _on_gamepiece_arriving(excess_distance: float) -> void:
	if not move_path.is_empty() and is_active:
		# Fast gamepieces could jump several waypoints at once, so check to see which waypoint is
		# next in line. 
		while not move_path.is_empty() and excess_distance > 0.0:
			if not Gameboard.pathfinder.can_move_to(move_path[0]):
				return
			
			var distance_to_waypoint: = _move_to_next_waypoint()
			excess_distance -= distance_to_waypoint


func _on_gamepiece_arrived() -> void:
	move_path.clear()
