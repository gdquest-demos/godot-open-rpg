extends Control

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var label: Label = $Label

export var offset := Vector2(0.0, -40.0)


func start(battler: Battler, type: String, message: String) -> void:
	# Initializes the node and starts its animation
	# @type: either health, mana, missed. Determines the animation the label will use
	assert(type in ['missed', 'mana', 'health'])
	var extents: RectExtents = battler.skin.get_extents()
	label.text = message

	var animation_name := ""
	if type == "missed":
		offset *= 2
		animation_name = type
	elif type == "health" or type == "mana":
		animation_name = type + "_loss" if int(message) <= 0 else type + "_gain"
	rect_global_position = battler.global_position - Vector2(0.0, extents.size.y) + offset
	anim_player.play(animation_name)
