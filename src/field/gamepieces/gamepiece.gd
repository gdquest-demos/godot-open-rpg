@tool

## A Gamepiece is a scene that is snapped to the [Gameboard].
class_name Gamepiece
extends Node2D

## Emitted when a gamepiece is about to finish travlling to its destination cell. The remaining
## distance that the gamepiece could travel is based on how far the gamepiece has travelled this
## frame. [br][br]
## The signal is emitted prior to wrapping up the path and traveller, allowing other objects to
## extend the move path, if necessary.
signal arriving(remaining_distance: float)

## Emitted when the gamepiece has finished travelling to its destination cell.
signal arrived
signal blocks_movement_changed
signal cell_changed(old_cell: Vector2i)
signal direction_changed(new_direction: Vector2)

## Emitted when the gamepiece begins to travel towards a destination cell.
signal travel_begun

const GROUP_NAME: = "_GAMEPIECES"

@export var grid: Grid:
	set(value):
		grid = value
		update_configuration_warnings()

@export var blocks_movement: = false:
	set(value):
		if value != blocks_movement:
			blocks_movement = value
			blocks_movement_changed.emit()

@export var max_speed: = 96.0

## The gamepiece's position is snapped to whichever cell it currently occupies. [br][br]
## The gamepiece will move by steps, being placed at whichever cell it currently occupies. This is
## useful for snapping it's collision shape to the grid, so that there is never ambiguity to which
## space/cell is occupied in the physics engine. [br][br]
## It is not desirable, however, for the graphical representation of the gamepiece (or the camera!)
## to jump around the gameboard with the gamepiece. Rather, a follower will travel a movement path
## to give the appearance of smooth movement. Other objects (such as sprites and animation) will
## derive their position from this follower and, consequently, appear to move smoothly.
var cell: = Vector2i.ZERO:
	set = set_cell

var direction: = Vector2.ZERO:
	set(value):
		value = value.normalized()
		if not direction.is_equal_approx(value):
			direction = value
			direction_changed.emit(direction)

var move_speed: = 64.0

## A camera will smoothly follow a travelling gamepiece by receiving the camera_anchor's transform.
@onready var camera_anchor: = $Decoupler/Path2D/PathFollow2D/CameraAnchor as RemoteTransform2D

## The graphical representation of the gamepiece may smoothly follow a travelling gamepiece by 
## receiving the gfx_anchor's transform.
@onready var gfx_anchor: = $Decoupler/Path2D/PathFollow2D/GFXAnchor as RemoteTransform2D

# The following objects allow the gamepiece to appear to move smoothly around the gameboard.
# Please note that the path is decoupled from the gamepiece's position (scale is set to match
# the gamepiece in _ready(), however) in order to simplify path management. All path coordinates may 
# be provided in game-world coordinates and will remain relative to the origin even as the 
# gamepiece's position changes.
@onready var _path: = $Decoupler/Path2D as Path2D
@onready var _follower: = $Decoupler/Path2D/PathFollow2D as PathFollow2D


func _ready() -> void:
	set_physics_process(false)
	update_configuration_warnings()
	
	if not Engine.is_editor_hint():
		assert(grid, "Gamepiece '%s' must have a grid to function!" % name)
		
		add_to_group(GROUP_NAME)
		
		move_speed = max_speed
		
		# Ensure that the gamepiece and its path are at the same scale. This will allow providing
		# movement coordinates in local scale, simplifying path creation.
		_path.global_scale = global_scale
		
		# Snap the gamepiece to it's initial grid position.
		# Note that the path's coordinates are decoupled from the gamepiece's in order to simplify
		# path creation (origin is the point of reference), so the follower needs to be initialized
		# to the gamepiece's position.
		cell = grid.pixel_to_cell(position)
		_follower.position = position


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not grid:
		warnings.append("Gamepiece requires a Grid object to function!")
	
	return warnings


func _physics_process(delta: float) -> void:
	var move_distance: = move_speed * delta
	
	# We need to let others know that the gamepiece will arrive at the end of its path THIS frame.
	# A controller may want to extend the path (for example, if a move key is held down or if
	# another waypoint should be added to the move path).
	# If we do NOT do so and the path is extended post arrival, there will be a single frame where
	# the gamepiece's velocity is discontinuous (drops, then increases again), causing jittery 
	# movement.
	# The excess travel distance allows us to know how much to extend the path by. A VERY fast
	# gamepiece may jump a few cells at a time.
	var excess_travel_distance: =  _follower.progress + move_distance \
		- _path.curve.get_baked_length()
	if excess_travel_distance >= 0:
		arriving.emit(excess_travel_distance)
	
	# Movement may have been extended, so check if we need to cap movement to the waypoint.
	var has_arrived: = _follower.progress + move_distance >= _path.curve.get_baked_length()
	if has_arrived:
		move_distance = _path.curve.get_baked_length() - _follower.progress
	
	var old_follower_position: = _follower.position
	_follower.progress += move_distance
	
	# This breaks down at very high speeds. At that point the cell path determines direction.
	direction = (_follower.position - old_follower_position).normalized()
	
	# If we've reached the end of the path, either travel to the next waypoint or wrap up movement.
	if has_arrived:
		_on_travel_finished()


## Calling travel_to_cell on a moving gamepiece will update it's position to that indicated by the
## cell coordinates and add the cell to the movement path.
func travel_to_cell(destination_cell: Vector2i) -> void:
	# Note that updating the gamepiece's cell will snap it to its new grid position. This will
	# be accounted for below when calculating the waypoint's pixel coordinates.
	var old_position: = position
	cell = destination_cell
	
	# If the gamepiece is not yet moving, we'll setup a new path.
	if not _path.curve:
		_path.curve = Curve2D.new()

		# The path needs at least two points for the follower to work correctly, so a new path
		# will travel from the gamepiece's old position.
		_path.curve.add_point(old_position)
		_follower.progress = 0
		
		set_physics_process(true)
	
	# The gamepiece serves as the waypoint's frame of reference.
	_path.curve.add_point(grid.cell_to_pixel(destination_cell))
	
	travel_begun.emit()


func is_moving() -> bool:
	return is_physics_processing()


func set_cell(value: Vector2i) -> void:
	if Engine.is_editor_hint():
		return
	
	var old_cell: = cell
	cell = value
	
	if not is_inside_tree():
		await ready
	
	print("Set cell to ", cell)
	
	var old_position: = position
	position = grid.cell_to_pixel(cell)
	_follower.position = old_position
	
	cell_changed.emit(old_cell)
	FieldEvents.gamepiece_cell_changed.emit(self, old_cell)


func _on_travel_finished() -> void:
	_path.curve = null
	_follower.progress = 0
		
	set_physics_process(false)
	arrived.emit()
