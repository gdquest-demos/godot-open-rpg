## The player controller focused on and able to move a particular [Gamepiece].
##
## Note that all gamepiece movement happens by passing a valid move path. The controller is a high
## level object responsible for coordinating different systems to find a valid path.
class_name CharacterController
extends Node

var focus: Gamepiece:
	set(value):
		if focus:
			focus.almost_arrived.disconnect(_on_focus_almost_arrived)
		
		focus = value
		set_is_active(not focus == null)
		
		focus.almost_arrived.connect(_on_focus_almost_arrived)

var is_active: = false:
	set = set_is_active

var _gamepieces: GamepieceDirectory = null
var _grid: Grid = null
var _pathfinder: Pathfinder = null


func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	set_process_unhandled_input(false)
	
	FieldEvents.cell_highlighted.connect(_on_FieldEvents_cell_highlighted)
	FieldEvents.cell_selected.connect(_on_FieldEvents_cell_selected)
	


func initialize(grid: Grid, directory: GamepieceDirectory, pathfinder: Pathfinder) -> void:
	_gamepieces = directory
	_grid = grid
	_pathfinder = pathfinder


func set_is_active(value: bool) -> void:
	assert(_gamepieces, "Cannot set is_active to true on controller with invalid "
		+ "GamepieceDirectory object!")
	if not focus or not _pathfinder or not _gamepieces:
		is_active = false
		return
	
	is_active = value
	
	set_process(is_active)
	set_physics_process(is_active)
	set_process_input(is_active)
	set_process_unhandled_input(is_active)


func _process(_delta: float) -> void:
	if focus.get_state() == Gamepiece.States.IDLE:
		var move_dir: = _get_move_direction()
		if move_dir:
			var target_cell: = Vector2i.ZERO
			
			# Unless using 8-direction movement, one movement axis must be preferred. 
			#	Default to the x-axis.
			if not is_zero_approx(move_dir.x):
				target_cell = focus.cell + Vector2i(int(move_dir.x), 0)
			else:
				target_cell = focus.cell + Vector2i(0, int(move_dir.y))
			
			# If there is a gamepiece at the target cell, do not move on top of it.
			var target_gamepiece: = _gamepieces.get_by_cell(target_cell)
			if target_gamepiece:
				pass
			
			# Otherwise, try to move to the target cell.
			else:
				var move_path: = _get_path_pixels(focus.cell, target_cell)
				
				# Path is invalid. Bump animation?
				if move_path.size() <= 1:
					pass
				
				else:
					focus.set_cell(target_cell)
					focus.travel_along_path(move_path)


func _get_move_direction() -> Vector2:
	return Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)


func _get_path_pixels(source_cell: Vector2i, target_cell: Vector2i) -> Array[Vector2i]:
	var point_px: Array[Vector2i] = []
		
	var cell_path: = _pathfinder.get_cell_path(source_cell, target_cell)
	for cell_i in cell_path:
		point_px.append(_grid.cell_to_pixel(cell_i))
		
	return point_px


func _on_focus_almost_arrived() -> void:
	var move_direction: = _get_move_direction()
	if move_direction:
		var next_cell: Vector2i
		if not is_zero_approx(move_direction.x):
			next_cell = focus.cell + Vector2i(int(move_direction.x), 0)
		else:
			next_cell = focus.cell + Vector2i(0, int(move_direction.y))
		
		if not _gamepieces.get_by_cell(next_cell) and \
				_get_path_pixels(focus.cell, next_cell).size() > 1:
			focus.set_cell(next_cell)
			focus.add_point_to_path(_grid.cell_to_pixel(next_cell))


func _on_FieldEvents_cell_highlighted(_cell: Vector2i) -> void:
	pass


func _on_FieldEvents_cell_selected(cell: Vector2i) -> void:
	if focus.get_state() == Gamepiece.States.IDLE:
		# Don't move to the cell the focus is standing on. May want to open inventory.
		if cell == focus.cell:
			return
		
		# We'll want different behaviour depending on what's underneath the cursor.
		# If there is an interactable gamepiece beneath the cursor, we'll walk next to the cell.
		var target_gamepiece: = _gamepieces.get_by_cell(cell)
		if target_gamepiece:
			var cell_path: = _pathfinder.get_cell_path_to_adjacent_cell(focus.cell, cell)
			if cell_path.size() > 1:
				var waypoints: Array[Vector2i] = []
				for path_cell in cell_path:
					waypoints.append(_grid.cell_to_pixel(path_cell))
				
				focus.set_cell(cell_path.back())
				focus.travel_along_path(waypoints)
		
		# If the cell beneath the cursor is empty the focus can follow a path to the cell.
		else:
			var point_path: = _get_path_pixels(focus.cell, cell)
			
			# Only follow a valid path.
			if point_path.size() > 1:
				focus.set_cell(cell)
				focus.travel_along_path(point_path)
