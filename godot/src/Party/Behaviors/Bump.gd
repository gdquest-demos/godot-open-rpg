extends Behavior
# Bump behavior.
#
# All it does is play a "bump" animation.


var _animation_player : AnimationPlayer = null


func run(msg: Dictionary = {}) -> void:
	if not root_node.is_walking:
		_animation_player.play("bump")
		yield(_animation_player, "animation_finished")
		_animation_player.play("<BASE>")


func _ready() -> void:
	_animation_player = $AnimationPlayer
	_animation_player.root_node = root_node.get_path()