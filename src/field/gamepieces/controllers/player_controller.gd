## A player controller that may be applied to any gamepiece.
##
## The controller responds to player input.
class_name PlayerController
extends GamepieceController

## Colliders matching the following mask will be used to determine which cells have [Interaction]s.
@export_flags_2d_physics var interaction_mask: = -1

# Keep track of the target of a path. Used to face/interact with the object at a path's end.
# It is reset on cancelling the move path or continuing movement via arrows/gamepad directions.
var _target: Gamepiece = null

# Keep track of a move path. The controller will check that the path is clear each time the 
# gamepiece needs to continue on to the next cell.
var _waypoints: Array[Vector2i] = []
var _current_waypoint: Vector2i

var _interaction_searcher: CollisionFinder


func _ready() -> void:
	super._ready()
	
	if not Engine.is_editor_hint():
		add_to_group(Groups.PLAYER_CONTROLLERS)
		
		var min_cell_axis: = minf(_gameboard.cell_size.x-1, _gameboard.cell_size.y-1) / 2.0
		_interaction_searcher = CollisionFinder.new(get_world_2d().direct_space_state, 
			min_cell_axis, interaction_mask)
		
		FieldEvents.cell_selected.connect(_on_cell_selected)
		
		is_active_changed.connect(_on_is_active_changed)
		
		_focus.arriving.connect(_on_focus_arriving)
		_focus.arrived.connect(_on_focus_arrived)


func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_released("interact"):
		var offset: = _focus.direction * Vector2(_gameboard.cell_size)
		if _run_event_at_position((_focus.position + offset) * global_scale):
			get_viewport().set_input_as_handled()


func _physics_process(_delta: float) -> void:
	if not _focus.is_travelling() and _focus.can_travel:
		var move_dir: = _get_move_direction()
		if move_dir:
			var target_cell: = Vector2i.ZERO
			
			# Unless using 8-direction movement, one movement axis must be preferred. 
			#	Default to the x-axis.
			if not is_zero_approx(move_dir.x):
				move_dir = Vector2(move_dir.x, 0)
			else:
				move_dir = Vector2(0, move_dir.y)
			
			_focus.direction = move_dir
			target_cell = _focus.cell + Vector2i(move_dir)
			
			# If there is a gamepiece at the target cell, do not move on top of it.
			_update_changed_cells()
			if not is_cell_blocked(target_cell) and \
					not FieldEvents.did_gp_move_to_cell_this_frame(target_cell):
				var move_path: = pathfinder.get_path_cells(_focus.cell, target_cell)
				
				# Path is invalid. Bump animation?
				if move_path.size() <= 1:
					pass
				
				else:
					_focus.travel_to_cell(target_cell)


func _get_move_direction() -> Vector2:
	return Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)


func _on_cell_selected(cell: Vector2i) -> void:
	if is_active and not _focus.is_travelling() and _focus.can_travel:
		# Don't move to the cell the focus is standing on. May want to open inventory.
		if cell == _focus.cell:
			return
			
		# We'll want different behaviour depending on what's underneath the cursor...
		_update_changed_cells()
		var collisions: = get_collisions(cell)
		
		# ...If the cell beneath the cursor is empty the focus can follow a path to the cell.
		if collisions.is_empty():
			_waypoints = pathfinder.get_path_cells(_focus.cell, cell)
		
		# ...Otherwise, if there is an interactable, blocking object beneath the cursor, we'll walk
		# *next* to the cell.
		else:
			for collision in collisions:
				var gamepiece: = collision.collider.owner as Gamepiece
				if gamepiece.blocks_movement:
					_target = gamepiece
					_waypoints = pathfinder.get_path_cells_to_adjacent_cell(_focus.cell, cell)
					break
		
		# Only follow a valid path with a length greater than 0 (more than one waypoint).
		if _waypoints.size() > 1:
			print(_waypoints)
			FieldEvents.player_path_set.emit(_focus, _waypoints.back())
			
			# The first waypoint is the focus' current cell and may be discarded.
			_waypoints.remove_at(0)
			_current_waypoint = _waypoints.pop_front()
			
			_focus.travel_to_cell(_current_waypoint)
		
		else:
			_waypoints.clear()


func _run_event_at_position(search_coordinates: Vector2) -> bool:
	var collisions: = _interaction_searcher.search(search_coordinates)
	for collision in collisions:
		var interactable = collision.collider as Interactable
		if interactable:
			interactable.run()
			return true
	return false


func _on_is_active_changed() -> void:
	if is_active and not _waypoints.is_empty():
		_waypoints.remove_at(0)
		_current_waypoint = _waypoints.pop_front()
		
		_focus.travel_to_cell(_current_waypoint)


# The controller's focus will finish travelling this frame unless it is extended.
# There are a few cases where the controller will want to extend the path:
#	a) The gamepiece is following a series of waypoints, and needs to know which cell is next. Note
#		that the controller is responsible for the waypoints (instead of the gamepiece, for
#		instance) so that the path can be checked for any changes *as the gamepiece travels*.
#	b) A movement key/button is held down and the gamepiece should smoothly flow into the next cell.
func _on_focus_arriving(excess_distance: float) -> void:
	# If the controller is not active, allow the gamepiece to arrive without interference.
	if not is_active:
		return

	var move_direction: = _get_move_direction()
	
	# If the gamepiece is currently following a path, continue moving along the path if it is still
	# a valid movement path since obstacles may shift while in transit.
	if not _waypoints.is_empty():
		while not _waypoints.is_empty() and excess_distance > 0:
			if is_cell_blocked(_waypoints[0]) \
					or FieldEvents.did_gp_move_to_cell_this_frame(_waypoints[0]):
				return
			
			_current_waypoint = _waypoints.pop_front()
			var distance_to_waypoint: = \
				_focus.position.distance_to(_gameboard.cell_to_pixel(_current_waypoint))
			
			_focus.travel_to_cell(_current_waypoint)
			excess_distance -= distance_to_waypoint
	
	# There is no path to follow, so defer to movement keys or buttons that are currently held down.
	elif move_direction:
		_target = null
		
		var next_cell: Vector2i
		if not is_zero_approx(move_direction.x):
			next_cell = _focus.cell + Vector2i(int(move_direction.x), 0)
		else:
			next_cell = _focus.cell + Vector2i(0, int(move_direction.y))
		
		if pathfinder.has_cell(next_cell) and not is_cell_blocked(next_cell) and \
				not FieldEvents.did_gp_move_to_cell_this_frame(next_cell):
			_focus.travel_to_cell(next_cell)


func _on_focus_arrived() -> void:
	# If the controller is not active, do not process further instructions and don't clear the 
	# waypoint list (in case the focus may continue walking when active again).
	if not is_active:
		return
	
	_waypoints.clear()
	
	if _target:
		var distance_to_target: = _target.position - _focus.position
		_focus.direction = distance_to_target
		
		_run_event_at_position(_target.position * global_scale)
		_target = null
