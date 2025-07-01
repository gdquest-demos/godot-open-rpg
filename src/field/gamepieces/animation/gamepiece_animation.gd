@tool
## Encapsulates [Gamepiece] animation as an optional component.
##
## Allows playing animations that automatically adapt to the parent
## [Gamepiece]'s direction by calling [method play]. Transitions between
## animations are handled automatically, including changes to direction.
## [br][br][b]Note:[/b] This is usually not added to the scene tree directly by
## the designer.
##
## Rather, it is typically added to a [Gamepiece] through the [member Gamepiece.animation_scene]
## property.
@icon("res://assets/editor/icons/GamepieceAnimation.svg")
class_name GamepieceAnimation extends Marker2D

## Name of the animation sequence used to reset animation properties to default.
## Note that this animation is only played for a single frame during animation
## transitions.
const RESET_SEQUENCE_KEY: = "RESET"

## Mapping that pairs cardinal [constant Directions.Points] with a [String] suffix.
const DIRECTION_SUFFIXES: = {
	Directions.Points.NORTH: "_n",
	Directions.Points.EAST: "_e",
	Directions.Points.SOUTH: "_s",
	Directions.Points.WEST: "_w",
}

## The animation currently being played.
var current_sequence_id: = "":
	set = play

## The direction faced by the gamepiece.
##
## Animations may optionally be direction-based. Setting the direction will use
## directional animations if they are available; otherwise non-directional
## animations will be used.
var direction: = Directions.Points.SOUTH:
	set = set_direction

@onready var _anim: = $AnimationPlayer as AnimationPlayer


## Change the currently playing animation to a new value, if it exists.
##
## Animations may be added with or without a directional suffix (i.e. _n for
## north/up). Directional animations will be preferred with direction-less
## animations as a fallback.
func play(value: String) -> void:
	if value == current_sequence_id:
		return

	if not is_inside_tree():
		await ready

	# We need to check to see if the animation is valid. First of all, look for
	# a directional equivalent - e.g. idle_n. If that fails, look for the new
	# sequence id itself.
	var sequence_suffix: String = DIRECTION_SUFFIXES.get(direction, "")
	if _anim.has_animation(value + sequence_suffix):
		current_sequence_id = value
		_swap_animation(value + sequence_suffix, false)

	elif _anim.has_animation(value):
		current_sequence_id = value
		_swap_animation(value, false)


## Change the animation's direction.
##
## If the currently running animation has a directional variant matching the new
## direction it will be played. Otherwise the direction-less animation will
## play.
func set_direction(value: Directions.Points) -> void:
	if value == direction:
		return

	direction = value

	if not is_inside_tree():
		await ready

	var sequence_suffix: String = DIRECTION_SUFFIXES.get(direction, "")
	if _anim.has_animation(current_sequence_id + sequence_suffix):
		_swap_animation(current_sequence_id + sequence_suffix, true)

	elif _anim.has_animation(current_sequence_id):
		_swap_animation(current_sequence_id, true)


## Transition to the next animation sequence, accounting for the RESET track and
## current animation elapsed time.
func _swap_animation(next_sequence: String, keep_position: bool) -> void:
	var next_anim = _anim.get_animation(next_sequence)

	if next_anim:
		# If keeping the current position, we want to do so as a ratio of the
		# position / animation length to account for animations of different length.
		var current_position_ratio = 0
		if keep_position:
			current_position_ratio = \
				_anim.current_animation_position / _anim.current_animation_length

		# RESET the animation immediately to its default reset state before the next sequence.
		# Take advantage of the default RESET animation to clear uncommon changes (i.e. flip_h).
		if _anim.has_animation(RESET_SEQUENCE_KEY):
			_anim.play(RESET_SEQUENCE_KEY)
			_anim.advance(0)

		_anim.play(next_sequence)
		_anim.advance(current_position_ratio * next_anim.length)
