extends Control

const popup_scene = preload("res://combat/interface/PopUp.tscn")


func initialize(battlers : Array) -> void:
	for battler in battlers:
		battler.stats.connect("health_changed", self, "_play_anim", [battler, "health"])
		battler.stats.connect("mana_changed", self, "_play_anim", [battler, "mana"])

func _play_anim(new_value, old_value, battler, signal_type):
	var value = new_value - old_value
	var new_position = Vector2(battler.position.x, battler.position.y - 250)
	
	var popup = popup_scene.instance()
	popup.rect_global_position = new_position
	popup.get_node("Label").text = str(value)
	var anim = popup.get_node("AnimationPlayer")
	
	add_child(popup)
	
	match signal_type:
		"health":
			if value <= 0:
				anim.play("damage")
			else:
				anim.play("heal")
		"mana":
			if value <= 0:
				anim.play("mana_loss")
			else:
				anim.play("mana_gain")
				