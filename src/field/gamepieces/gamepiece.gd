@tool

## A Gamepiece is a scene that occupies a cell on the [Gameboard].
##
## Gamepieces are moved by assigning a path via [method travel_along_path] which uses pixel
## coordinates. Often these are derived from a cell-based path, but not always (e.g. cutscenes).
## They may also return to the cell they occupy immediately by calling 
## [method place_at_current_cell].[br][br]
##
## For a gamepiece to be visible it must be assigned a [CharacterAnimation] via 
## [method set_animation].
class_name Gamepiece
extends Node2D

signal almost_arrived
signal arrived
signal blocks_movement_changed
signal cell_changed(old_cell: Vector2i)
signal freed

enum States { IDLE, TRAVEL, BUSY }

## The proxy used to set [member _animation], a reference to the gamepieces's [CharacterAnimation] 
## scene. [PackedScene]s that are not derived from [CharacterAnimation] will not be accepted.
@export var animation_scene: PackedScene:
	set = set_animation

@export var blocks_movement: = false:
	set(value):
		if value != blocks_movement:
			blocks_movement = value
			blocks_movement_changed.emit()

@export var move_speed: = 750.0

@export var _grid: Grid

var cell: = Vector2i.ZERO:
	set = set_cell

var _animation: CharacterAnimation = null

var _state: = States.IDLE:
	set = set_state

@onready var camera_anchor: = $Path2D/PathFollower/GFX/CameraAnchor as RemoteTransform2D
@onready var _path: = $Path2D as Path2D
@onready var _path_follower: = $Path2D/PathFollower as PathFollow2D


func _ready() -> void:
	set_process(false)
	set_process_unhandled_input(false)
	
	# A gamepiece must be initialized with several properties before it can function in-game. 
	# By default, hide the gamepiece until it has been intialized to prevent it appearing 
	#	incorrectly or at an incorrect location.
	if not Engine.is_editor_hint():
		hide()


@warning_ignore("native_method_override")
func queue_free() -> void:
	freed.emit()
	super.queue_free()


func _process(delta: float) -> void:
	var move_distance: = move_speed * delta
	
	# We need to let the controller know that the gamepiece will arrive at the end of its path THIS
	# frame. The controller may want to extend the path (for example, if a move key is held down).
	# If we do NOT do so, there will be a single frame where the gamepiece's velocity drops,
	# causing jittery movement.
	if _path_follower.progress + move_distance >= _path.curve.get_baked_length():
		almost_arrived.emit()
	
	_path_follower.progress += move_distance
	
	# Determine the gamepiece's facing based on the current offset along the move path.
	if _animation:
		var current_transform: = _path.curve.sample_baked_with_rotation(_path_follower.progress, 
			_path_follower.cubic_interp)
		var current_facing: = Directions.angle_to_direction(current_transform.get_rotation() - PI/2)
		_animation.set_facing(current_facing)
	
	# If we've reached the end of the path, wrap up movement.
	if _path_follower.progress >= _path.curve.get_baked_length():
		_on_travel_finished()


# Will be used to pause travel along the current path.
func _unhandled_input(_event: InputEvent) -> void:
	pass


## Setup the gamepiece, including dependencies needed for it to function correctly.
##
## A gamepiece is normally automatically initialized by the [Gameboard] after it has been added to
## the correct location.
func initialize(grid: Grid) -> void:
	_grid = grid
	
	# Move the gamepiece to occupy the cell closest to its position (placed in editor, usually).
	set_cell(_grid.pixel_to_cell(position))
	position = _grid.cell_to_pixel(cell)
	
	show()
	
	FieldEvents.gamepiece_initialized.emit(self)


func place_at_current_cell() -> void:
	position = _grid.cell_to_pixel(cell)


func add_point_to_path(waypoint: Vector2) -> void:
	if _path.curve:
		_path.curve.add_point(waypoint-position)


func travel_along_path(waypoints: PackedVector2Array) -> void:
	if waypoints.is_empty():
		_follow_curve(null)

	else:
		var new_curve: = Curve2D.new()
		new_curve.add_point(Vector2i(0, 0))
		
		for point in waypoints:
			new_curve.add_point(point-position)

		_follow_curve(new_curve)


func set_animation(value: PackedScene) -> void:
	var animation_value: CharacterAnimation = null
	
	if not is_inside_tree():
		await ready
	
	# Instantiate the provided PackedScene to ensure that it's a valid CharacterAnimation.
	if value:
		var instance: = value.instantiate()
		animation_value = instance as CharacterAnimation
		
		if not animation_value:
			print("%s::set_animation() error - value is not a CharacterAnimation scene!" % name)
			instance.free()
			return
	
	# value is a valid CharacterAnimation scene, so free up any old animation objects and assign the
	# new animation.
	if _animation:
		_animation.queue_free()
	
	animation_scene = value
	_animation = animation_value
	
	if _animation:
		$Path2D/PathFollower/GFX.add_child(_animation)
		_animation.owner = self


func get_animation() -> CharacterAnimation:
	return _animation


func set_cell(value: Vector2i) -> void:
	var old_cell: = cell
	cell = value
	
	cell_changed.emit(old_cell)


func set_state(value: States) -> void:
	_state = value
	match _state:
		States.TRAVEL:
			if _animation:
				_animation.play("run")
		_:
			if _animation:
				_animation.play("idle")
	
	set_process(_state == States.TRAVEL)
	set_process_unhandled_input(_state == States.TRAVEL)


func get_state() -> States:
	return _state


## Walk along the set path. 
## There may be multiple ways to create a path, but only _follow_curve will begin travel.
func _follow_curve(new_curve: Curve2D) -> void:
	_reset_path()
	
	_path.curve = new_curve
	
	if _path.curve and not _path.curve.get_baked_points().is_empty():
		_state = States.TRAVEL
	
	else:
		_on_travel_finished()


## Stop moving, update the gamepiece's position, and reset all movement variables to 0.
func _reset_path() -> void:
	position += _path_follower.position
	_path_follower.position = Vector2.ZERO
	
	_path.curve = null
	_path_follower.progress = 0.0
	
	set_process(false)
	set_process_unhandled_input(false)


func _on_travel_finished() -> void:
	_reset_path()
	place_at_current_cell()
	
	_state = States.IDLE
