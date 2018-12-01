extends Control

onready var anim_player = get_node("AnimationPlayer")
var _animation_name : String

func initialize(battler : Battler, type : String, difference : int):
	"""
	@type: either health or mana. Determines the animation the label will use
	"""
	assert type in ["health", "mana"]
	# TODO: get height from the battler
	rect_global_position = Vector2(battler.position.x, battler.position.y - 250)
	get_node("Label").text = str(difference)
	_animation_name = type + "_loss" if difference <= 0 else type + "_gain"

func play() -> void:
	anim_player.play(_animation_name)
