@tool

## A Gamepiece is a scene that moves about and is snapped to the gameboard.
##
## Gamepieces, like other scenes in Godot, are expected to be composed from other nodes (i.e. an AI
## [GamepieceController], a collision shape, or a [Sprite2D], for example). Gamepieces themselves
## are 'dumb' objects that do nothing but occupy and move about the gameboard.
##
## [br][br][b]Note:[/b] The [code]gameboard[/code] is considered to be the playable area on which a
## Gamepiece may be placed. The gameboard is made up of cells, each of which may be occupied by one
##  or more gamepieces.
@icon("res://assets/editor/icons/Gamepiece.svg")
class_name Gamepiece extends Path2D

## Emitted when a gamepiece is about to finish travlling to its destination cell. The remaining
## distance that the gamepiece could travel is based on how far the gamepiece has travelled this
## frame. [br][br]
## The signal is emitted prior to wrapping up the path and traveller, allowing other objects to
## extend the move path, if necessary.
signal arriving(remaining_distance: float)

## Emitted when the gamepiece has finished travelling to its destination cell.
signal arrived

## Emitted when the gamepiece's [member direction] changes, usually as it travels about the board.
signal direction_changed(new_direction: Directions.Points)

## A [GamepieceAnimation] packed scene that will be automatically added to the gamepiece. Other
## scene types will not be accepted.
@export var animation_scene: PackedScene:
	set(value):
		animation_scene = value

		if not is_inside_tree():
			await ready

		if animation:
			animation.queue_free()
			animation = null

		if animation_scene:
			# Check to make sure that the supplied scene instantiates as a GamepieceAnimation.
			var new_scene: = animation_scene.instantiate()
			animation = new_scene as GamepieceAnimation
			if not animation:
				printerr("Gamepiece '%s' cannot accept '%s' as " % [name, new_scene.name],
					"gamepiece_gfx_scene. '%s' is not a GamepieceGFX object!" % new_scene.name)
				new_scene.free()
				animation_scene = null
				return

			follower.add_child(animation)

## The gamepiece will traverse a movement path at [code]move_speed[/code] pixels per second.
##
## Note that extremely high speeds (finish a long path in a single frame) will produce
## unexpected results.
@export var move_speed: = 64.0

## The visual representation of the gamepiece, set automatically based on [member animation_scene].
## Usually the animation is only changed by the gamepiece itself, though the designer may want to
## play different animations sometimes (such as during a cutscene).
var animation: GamepieceAnimation = null

## The [code]direction[/code] is a unit vector that points where the gamepiece is 'looking'.
## In the event that the gamepiece is moving along a path, direction is updated automatically as
## long as the gamepiece continues to move.
var direction: = Directions.Points.SOUTH:
	set(value):
		if value != direction:
			direction = value

			if not is_inside_tree():
				await ready

			animation.direction = direction
			direction_changed.emit(direction)

## The position at the centre of the cell currently occupied by the gamepiece. Note that this
## differs from the gamepiece's position while it is moving.
var rest_position: = Vector2.ZERO

## The position at the centre of the cell to which the gamepiece is currently moving (and which it
## currently occupies, as it moves towards it).
## Compare this with the Gamepiece's position, which is kept constant at the move path's origin
## until the gamepiece has arrived at its destination. Compare also with the position of the path
## follower, at which the GamepieceAnimation is rendered.
var destination: Vector2

## Node2Ds may want to follow the gamepiece's animation, rather than position (which updates only at
## the end of a path). Nodes may follow a travelling gamepiece by receiving the path follower's
## transform.
##
## The [member RemoteTransform2D.remote_path] is reserved for the player camera, but other nodes
## may access the anchor's position directly.
@onready var animation_transform: = $PathFollow2D/CameraAnchor as RemoteTransform2D

# The following objects allow the gamepiece to appear to move smoothly around the gameboard.
# Please note that the path is decoupled from the gamepiece's position (scale is set to match
# the gamepiece in _ready(), however) in order to simplify path management. All path coordinates may
# be provided in game-world coordinates and will remain relative to the origin even as the
# gamepiece's position changes.
@onready var follower: = $PathFollow2D as PathFollow2D


func _ready() -> void:
	set_process(false)

	if not Engine.is_editor_hint() and is_inside_tree():
		# Some gamepieces may be added to the scene before the Gameboard properties are set. In that
		# case, wait for Gameboard dimensions to be set before registering the gamepiece.
		if Gameboard.properties == null:
			await Gameboard.properties_set

		# Snap the gamepiece to the cell on which it is standing.
		var cell: = Gameboard.get_cell_under_node(self)
		position = Gameboard.cell_to_pixel(cell)

		# Then register the gamepiece with the registry. Note that if a gamepiece already exists at
		# the cell, this one will simply be freed.
		if GamepieceRegistry.register(self, cell) == false:
			queue_free()


func _process(delta: float) -> void:
	# How far will the gamepiece move this frame?
	var move_distance: = move_speed * delta

	# We need to let others know that the gamepiece will arrive at the end of its path THIS frame.
	# A controller may want to extend the path (for example, if a move key is held down or if
	# another waypoint should be added to the move path).
	# If we do NOT do so and the path is extended post arrival, there will be a single frame where
	# the gamepiece's velocity is discontinuous (drops, then increases again), causing jittery
	# movement.
	# The excess travel distance allows us to know how much to extend the path by. A VERY fast
	# gamepiece may jump a few cells at a time.
	var excess_travel_distance: =  follower.progress + move_distance - curve.get_baked_length()
	if excess_travel_distance >= 0.0:
		arriving.emit(excess_travel_distance)

	# The path may have been extended, so the gamepiece can move along the path now.
	follower.progress += move_distance

	# Figure out which direction the gamepiece is facing, making sure that the GamepieceAnimation
	# scene doesn't rotate.
	animation.global_rotation = 0
	direction = Directions.angle_to_direction(follower.rotation)

	# If the gamepiece has arrived, update it's position and movement details.
	if follower.progress >= curve.get_baked_length():
		stop()


## Move the gamepiece towards a point, given in pixel coordinates.
## If the Gamepiece is currently moving, this point will be added to the current path (see
## [member Path2D.curve]. Otherwise, a new curve is created with the point as the target.[br][br]
## Note that the Gamepiece's position will remain fixed until it has fully traveresed its movement
## path. At this point, its position is then updated to its destination.
func move_to(target_point: Vector2) -> void:
	# Note that the destination is where the gamepiece will end up in game world coordinates.
	destination = target_point
	set_process(true)

	if curve == null:
		curve = Curve2D.new()
		curve.add_point(Vector2.ZERO)

		animation.play("run")

	# The positions on the path, however, are all relative to the gamepiece's current position. The
	# position doesn't update until the Gamepiece reaches its final destination, otherwise the path
	# would move along with the gamepiece.
	curve.add_point(destination-position)


## Stop the gamepiece from travelling and update its position.
func stop() -> void:
	# Sort out gamepiece position, resetting the follower and placing everything at the destination.
	position = destination
	follower.progress = 0
	curve = null
	destination = Vector2.ZERO

	# Handle the change to animation.
	animation.global_rotation = 0
	animation.play("idle")

	# Stop movement and update logic.
	set_process(false)
	arrived.emit()


## Returns [code]true[/code] if the gamepiece is currently moving along its [member Path2D.curve].
func is_moving() -> bool:
	return is_processing()
