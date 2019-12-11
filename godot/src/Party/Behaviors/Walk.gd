extends Behavior
# Walk behavior that linearly moves `root_node` at the speed of the walk animation.
#
# It also detects for encounters at the end of the walk. Only the leader node should have the
# Detect scene attached as a Node. This is done in the `setup(detect, remote_transofrm)` function
# from Member script.


var _tween : Tween = null
var _animation_player : AnimationPlayer = null
var _rng : = RandomNumberGenerator.new()
var _speed : float = 0.0


func run(msg: Dictionary = {}) -> void:
	if not "path" in msg:
		return

	root_node.is_walking = not root_node.is_walking
	_animation_player.play("walk")
	_animation_player.seek(
			_rng.randf_range(0, 0.5 * _animation_player.current_animation_length))

	for i in range(msg.path.size() - 1):
		_tween.interpolate_property(
				root_node, "position",
				msg.path[i], msg.path[i + 1], _speed,
				Tween.TRANS_LINEAR, Tween.EASE_IN)
		_tween.start()
		yield(_tween, "tween_completed")
	
	root_node.is_walking = not root_node.is_walking
	_animation_player.play("<BASE>")
	msg = {is_leader = root_node.is_leader, encounter = which_encounter()}
	root_node.emit_signal("walked", msg)


# Checks the four cardinal directions for Encounters.
#
# Returns the Encounter if it could find it.
func which_encounter() -> Area2D:
	var out : = null
	if root_node.is_leader and root_node.has_node("Detect"):
		for ray in root_node.get_node("Detect").get_children():
			var obj : Area2D = ray.get_collider()
			if obj != null and obj.is_in_group("encounters"):
				out = obj
				break
	return out


func _ready() -> void:
	_tween = $Tween
	_animation_player = $AnimationPlayer
	
	_animation_player.root_node = root_node.get_path()
	_speed = _animation_player.get_animation("walk").length
	_rng.randomize()
