extends Control

onready var label = $Label
onready var anim = $AnimationPlayer

func initialize(battlers : Array) -> void:
	for battler in battlers:
		#battler.stats.connect("health_changed", self, "_on_Battler_health_changed", [battler])
		battler.stats.connect("mana_changed", self, "_on_Battler_mana_changed", [battler])

func _on_Battler_health_changed(new_value, old_value, battler) -> void:
	var value = new_value - old_value
	rect_position = Vector2(battler.position.x, battler.position.y - 150)
	label.text = str(value)
	if value <= 0:
		anim.play("damage")
		pass
	else:
		anim.play("heal")

func _on_Battler_mana_changed(new_value, old_value, battler) -> void:
	var value = new_value - old_value
	rect_position = Vector2(battler.position.x, battler.position.y - 150)
	label.text = str(value)
	print(label.text)
	if value <= 0:
		#anim.play("mana_loss") #not added yet
		anim.play("damage")
	else:
		#anim.play("mana_gain") #not added yet
		anim.play("heal")
