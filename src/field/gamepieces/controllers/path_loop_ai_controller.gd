@tool
extends GamepieceController

## The points in the path_to_follow will be used to generate the waypoints that the controller will
## follow.
@export var path_to_follow: Line2D:
	set(value):
		path_to_follow = value
		update_configuration_warnings()

var _current_waypoint_index: = -1
var _path_origin: = Vector2.ZERO
var _start_cell: = Vector2i.ZERO

# The Gamepiece will wait for the timer to elapse before starting on its path.
# The timer will also trigger between iterations of the path. This means that after the gamepiece
# has looped back to the original point it will wait for _timer.timeout before beginning the next
# loop.
# The timer will also trigger if the path becomes blocked, for some reason.
@onready var _timer: Timer = $WaitTimer


func _ready() -> void:
	if not Engine.is_editor_hint():
		path_to_follow.hide()
		_path_origin = _gamepiece.position
		
		# The controller cannot find a path until the pathfinder has updated, and changes may
		# require a new path. Update whenever the pathfinder changes.
		Gameboard.pathfinder_changed.connect(
			func _on_pathfinder_changed(_added, _removed) -> void:
				# Log an error if the path described by path_to_follow cannot be traversed.
				if not _find_move_path():
					#printerr("Failed to find a path_to_follow for '%s'!" % _gamepiece.name)
					return
		)
		
		_timer.one_shot = true
		_timer.timeout.connect(_move_to_next_waypoint)
		_timer.start()
	
	super._ready()


# Override GamepieceController's default implementation to preserve the move_path and to make use
# of the wait timer, if it is active.
func set_is_active(value: bool) -> void:
	is_active = value
	
	## Pause/unpause the wait timer to match the controller's 'paused state'. This is only really
	## relevant if the controller is currently waiting to run the next loop.
	_timer.paused = !is_active
	
	## Otherwise, if the gamepiece is in transit, pick up where it had left off.
	if _timer.is_stopped():
		_move_to_next_waypoint()

#func set_is_paused(paused: bool) -> void:
	#is_paused = paused
	#
	## Pause/unpause the wait timer to match the controller's 'paused state'. This is only really
	## relevant if the controller is currently waiting to run the next loop.
	#_timer.paused = is_paused
	#
	## Otherwise, if the gamepiece is in transit, pick up where it had left off.
	#if not paused:
		#if _current_waypoint_index > 0 and _current_waypoint_index < _waypoints.size() - 1 and \
				#not is_cell_blocked(_waypoints[_current_waypoint_index]):
			#_gamepiece.travel_to_cell(_waypoints[_current_waypoint_index])


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	# Node exports are currently broken.
	if not path_to_follow:
		warnings.append("The path loop controller needs a valid Line2D to follow!")
	
	return warnings


# Try to convert the path_to_follow into a series of cells for the gamepiece to move to.
# Loop through the points in the Line2D, using Gameboard.pathfinder to find a path to each. Also
# searches for the shortest path from the last point to the first point.
# This method will fail if there is no valid path on the Gameboard between line points.
func _find_move_path() -> bool:
	move_path.clear()
	
	# A path needs at least two points.
	if path_to_follow.get_point_count() <= 1:
		return false
	
	# Add the first cell to the path, since subsequent additions will have the first cell removed.
	_start_cell = Gameboard.pixel_to_cell(path_to_follow.get_point_position(0) + _path_origin)
	#move_path.append(Gameboard.pixel_to_cell(path_to_follow.get_point_position(0) + _path_origin))
	
	# Create a looping path from the points specified by path_to_follow. Will fail if a path cannot
	# be found between some of the path_to_follow's points.
	for i in range(1, path_to_follow.get_point_count()):
		var source: = Gameboard.pixel_to_cell(path_to_follow.get_point_position(i-1) + _path_origin)
		var target: = Gameboard.pixel_to_cell(path_to_follow.get_point_position(i) + _path_origin)
		
		var path_segment: = Gameboard.pathfinder.get_path_to_cell(source, target,
			Pathfinder.FLAG_ALLOW_SOURCE_OCCUPANT | Pathfinder.FLAG_ALLOW_TARGET_OCCUPANT)
		if path_segment.is_empty():
			#push_error("'%s' PathLoopAiController::_find_waypoints_from_line2D() error - " % name +
				#"Failed to find a path between cells %s and %s." % [source, target])
			return false
		
		move_path.append_array(path_segment)
	
	# Finally, connect the ending and starting cells to complete the loop.
	var last_pos: = path_to_follow.get_point_position(path_to_follow.get_point_count()-1) \
		+ _path_origin
	var last_cell: = Gameboard.pixel_to_cell(last_pos)
	var first_cell: = Gameboard.pixel_to_cell(path_to_follow.get_point_position(0) + _path_origin)
	
	# If we've made it this far there must be a path between the first and last cell.
	if last_cell != first_cell:
		move_path.append_array(Gameboard.pathfinder.get_path_to_cell(last_cell, first_cell, 
			Pathfinder.FLAG_ALLOW_SOURCE_OCCUPANT | Pathfinder.FLAG_ALLOW_TARGET_OCCUPANT))
	return true


func _get_next_waypoint_index() -> int:
	var next_index: = _current_waypoint_index + 1
	if next_index >= move_path.size():
		next_index = 0
	return next_index


func _move_to_next_waypoint() -> float:
	var distance_to_point: = 0.0
	
	if is_active and not move_path.is_empty():
		var next_index: = _get_next_waypoint_index()
		
		# If the next waypoint is blocked, restart the timer and try again later.
		if Gameboard.pathfinder.can_move_to(move_path[next_index]):
			_current_waypoint_index = next_index
			_current_waypoint = move_path[_current_waypoint_index]
			
			var destination = Gameboard.cell_to_pixel(_current_waypoint)
			distance_to_point = _gamepiece.position.distance_to(destination)
			_gamepiece.move_to(destination)
			
			GamepieceRegistry.move_gamepiece(_gamepiece, _current_waypoint)
			
		
		else:
			_timer.start()
	
	return distance_to_point


# Modified from the default behaviour to always wait for wait_timer.timeout on the last point.
func _on_gamepiece_arriving(excess_distance: float) -> void:
	if not move_path.is_empty() and is_active:
		# Fast gamepieces could jump several waypoints at once, so check to see which waypoint is
		# next in line. 
		while not move_path.is_empty() and excess_distance > 0.0:
			if _current_waypoint == _start_cell \
					or not Gameboard.pathfinder.can_move_to(move_path[_get_next_waypoint_index()]):
				return
			
			var distance_to_waypoint: = _move_to_next_waypoint()
			excess_distance -= distance_to_waypoint


# Override GamepieceController's default implementation to preserve the move_path.
#func _on_gamepiece_arriving(excess_distance: float) -> void:
	#if not is_active:
		#return
	#
	## If the gamepiece is currently following a path, continue moving along the path if it is still
	## a valid movement path since obstacles may shift while in transit.
	#while _current_waypoint_index >= 0 and _current_waypoint_index < move_path.size() - 1 \
			#and excess_distance > 0:
		#_current_waypoint_index += 1
		#var waypoint: = move_path[_current_waypoint_index]
		#
		## If the gamepiece cannot move to the next cell in the path, begin the timer and wait for
		## the path to reopen.
		#if not Gameboard.can_move_to(waypoint):
			#return
		#
		#var distance_to_waypoint: = \
			#_gamepiece.position.distance_to(Gameboard.cell_to_pixel(waypoint))
		#
		#_gamepiece.travel_to_cell(waypoint)
		#excess_distance -= distance_to_waypoint


# Override GamepieceController's implementation to preserve the move_path.
func _on_gamepiece_arrived() -> void:
	_timer.start()


# Restart the path from the Gamepiece's current cell. If the next waypoint is blocked, the timer
# will be restarted.
#func _on_timer_timeout() -> void:
	#if _current_waypoint_index < 0 or _current_waypoint_index >= move_path.size():
		#_current_waypoint_index = 0
	#
	#_current_waypoint = move_path[_current_waypoint_index]
	#if _current_waypoint == _gamepiece.cell:
		#_current_waypoint_index += 1
		#if _current_waypoint_index >= move_path.size():
			#_current_waypoint_index = 0
		#_current_waypoint = move_path[_current_waypoint_index]
	#
	## If the next waypoint is blocked, restart the timer and try again laer.
	#if _current_waypoint != _gamepiece.cell and \
			#not Gameboard.pathfinder.can_move_to(_current_waypoint):
		#_timer.start()
	#
	#else:
		#_gamepiece.move_to(Gameboard.cell_to_pixel(_current_waypoint))
