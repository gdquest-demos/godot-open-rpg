## Specialized camera that is constrained to the [Gameboard]'s boundaries.
##
## The camera's limits are set dynamically according to the viewport's dimensions. Normally, the
## camera is limited to the [member Gameboard.boundaries].
## [br][br]In some cases the gameboard is smaller than the viewport, in which case it will be
## snapped to the gameboard centre along the constrained axis/axes.
class_name FieldCamera
extends Camera2D

@export var gameboard: Gameboard:
	set(value):
		_on_viewport_resized()


@export var gamepiece: Gamepiece:
	set(value):
		if gamepiece:
			gamepiece.camera_anchor.remote_path = ""
		
		gamepiece = value
		if gamepiece:
			gamepiece.camera_anchor.remote_path = gamepiece.camera_anchor.get_path_to(self)


func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()


func reset_position() -> void:
	if gamepiece:
		position = gamepiece.position * scale
		
	reset_smoothing()


func _on_viewport_resized() -> void:
	if not gameboard:
		return
	
	# Calculate tentative camera boundaries based on the gameboard.
	var boundary_left: = gameboard.boundaries.position.x * gameboard.cell_size.x
	var boundary_top: = gameboard.boundaries.position.y * gameboard.cell_size.y
	var boundary_right: = gameboard.boundaries.end.x * gameboard.cell_size.x
	var boundary_bottom: = gameboard.boundaries.end.y * gameboard.cell_size.y

	# We'll also want the current viewport boundary sizes.
	var vp_size: = get_viewport_rect().size / global_scale
	var boundary_width: = boundary_right - boundary_left
	var boundary_height: = boundary_bottom - boundary_top

	# If the boundary size is less than the viewport size, the camera limits will be smaller than
	# the camera dimensions (which does all kinds of crazy things in-game).
	# Therefore, if this is the case we'll want to centre the camera on the gameboard and set the
	# limits to be that of the viewport, locking the camera to one or both axes.
	# Start by checking the x-axis.
	# Note that the camera limits must be in global coordinates to function correctly, so account
	# using the global scale.
	if boundary_width < vp_size.x:
		# Set the camera position to the centre of the gameboard.
		position.x = (gameboard.boundaries.position.x + gameboard.boundaries.size.x/2.0) \
			* gameboard.cell_size.x

		# And add/subtract half the viewport dimension to come up with the limits. This will fix the
		# camera with the gameboard centred.
		limit_left = (position.x - vp_size.x/2.0)*global_scale.x as int
		limit_right = (position.x + vp_size.x/2.0)*global_scale.x as int

	# If, however, the viewport is smaller than the gameplay area, the camera can be free to move
	# as needed.
	else:
		limit_left = boundary_left*global_scale.x as int
		limit_right = boundary_right*global_scale.x as int

	# Perform the same checks as above for the y-axis.
	if boundary_height < vp_size.y:
		position.y = (gameboard.boundaries.position.y + gameboard.boundaries.size.y/2.0) \
			* gameboard.cell_size.y
		limit_top = (position.y - vp_size.y/2.0)*global_scale.y as int
		limit_bottom = (position.y + vp_size.y/2.0)*global_scale.y as int
	else:
		limit_top = boundary_top*global_scale.y as int
		limit_bottom = boundary_bottom*global_scale.y as int
