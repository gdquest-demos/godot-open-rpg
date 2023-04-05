@tool
## Encapsulates character (field gamepiece, battler, etc.) animation in a swappable object.
class_name CharacterAnimation
extends Marker2D

const RESET_SEQUENCE_KEY: = "RESET"

const DIRECTION_SUFFIXES: = {
	Directions.Points.N: "_n",
	Directions.Points.E: "_e",
	Directions.Points.S: "_s",
	Directions.Points.W: "_w",
}

var current_sequence_id: = "":
	set = play

## Animations may optionally be direction-based. Setting the facing will use directional animations
## if they are available; otherwise non-directional animations will be used.
var facing: = Directions.Points.N:
	set = set_facing

@onready var _anim: = $AnimationPlayer as AnimationPlayer


func play(value: String) -> void:
	if value == current_sequence_id:
		return
	
	if not is_inside_tree():
		await ready
	
	# We need to check to see if the animation is valid.
	# First of all, look for a directional equivalent - e.g. idle_n. If that fails, look for 
	# the new sequence id itself.
	var sequence_suffix: String = DIRECTION_SUFFIXES.get(facing, "")
	if _anim.has_animation(value + sequence_suffix):
		current_sequence_id = value
		_swap_animation(value + sequence_suffix, false)
	
	elif _anim.has_animation(value):
		current_sequence_id = value
		_swap_animation(value, false)


func set_facing(value: Directions.Points) -> void:
	if value == facing:
		return
	
	facing = value
	
	if not is_inside_tree():
		await ready
	
	var sequence_suffix: String = DIRECTION_SUFFIXES.get(facing, "")
	if _anim.has_animation(current_sequence_id + sequence_suffix):
		_swap_animation(current_sequence_id + sequence_suffix, true)
	
	elif _anim.has_animation(current_sequence_id):
		_swap_animation(current_sequence_id, true)


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
