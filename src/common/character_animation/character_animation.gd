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
		_swap_animation(value + sequence_suffix)
	
	elif _anim.has_animation(value):
		current_sequence_id = value
		_swap_animation(value)


func set_facing(value: Directions.Points) -> void:
	if value == facing:
		return
	
	facing = value
	
	if not is_inside_tree():
		await ready
	
	var sequence_suffix: String = DIRECTION_SUFFIXES.get(facing, "")
	if _anim.has_animation(current_sequence_id + sequence_suffix):
		_swap_animation(current_sequence_id + sequence_suffix)
	
	elif _anim.has_animation(current_sequence_id):
		_swap_animation(current_sequence_id)


# RESET the animation immediately to its default reset state before queuing the next sequence.
# Take advantage of the default RESET animation to clear uncommon changes (i.e. flip_h).
func _swap_animation(next_sequence: String) -> void:
	if _anim.has_animation(RESET_SEQUENCE_KEY):
		_anim.play(RESET_SEQUENCE_KEY)
		_anim.advance(0)
	
	_anim.play(next_sequence)
