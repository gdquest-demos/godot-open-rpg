extends Control

onready var anim_player = get_node("AnimationPlayer")
var _animation_name : String

export var offset : Vector2 = Vector2(0.0, -40.0)

func initialize(battler : Battler, type : String, message : String):
	"""
	@type: either health, mana, missed. Determines the animation the label will use
	"""
	assert type in ["health", "mana", "missed"]
	var battler_extents : RectExtents = battler.skin.get_extents()
	get_node("Label").text = message
	if type == "missed":
		offset = offset * 2
		_animation_name = type
	elif type == "health" or type == "mana":
		_animation_name = type + "_loss" if int(message) <= 0 else type + "_gain"
	rect_global_position = battler.global_position - Vector2(0.0, battler_extents.size.y) + offset
	
func play() -> void:
	anim_player.play(_animation_name)
	
