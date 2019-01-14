extends Control

onready var anim_player = get_node("AnimationPlayer")
var _animation_name : String

export var offset : Vector2 = Vector2(0.0, -40.0)

func initialize_damage(battler : Battler, type : String, difference : int):
	"""
	@type: either health or mana. Determines the animation the label will use
	"""
	assert type in ["health", "mana"]
	var battler_extents : RectExtents = battler.skin.get_extents()
	rect_global_position = battler.global_position - Vector2(0.0, battler_extents.size.y) + offset
	get_node("Label").text = str(difference)
	_animation_name = type + "_loss" if difference <= 0 else type + "_gain"

func initialize_status(battler : Battler, type : String, message : String):
	assert type in ["miss"]
	var battler_extents : RectExtents = battler.skin.get_extents()
	rect_global_position = battler.global_position - Vector2(0.0, battler_extents.size.y) + (offset * 2)
	get_node("Label").text = message
	_animation_name = type

func play() -> void:
	anim_player.play(_animation_name)
	
