extends Control

const label_scene = preload("PopupLabel.tscn")

func initialize(battlers : Array) -> void:
	for battler in battlers:
		battler.stats.connect("health_changed", self, "spawn_label_number", [battler, "health"])
		battler.stats.connect("mana_changed", self, "spawn_label_number", [battler, "mana"])
		for skill in battler.skills.get_children():
			skill.connect("attack_status", self, "spawn_label_text", [battler, "miss"])

func spawn_label_number(new_value : int, old_value : int, battler : Battler, signal_type : String) -> void:
	var difference = new_value - old_value
	var damage_label = label_scene.instance()
	damage_label.initialize_damage(battler, signal_type, difference)
	add_child(damage_label)
	damage_label.play()

func spawn_label_text(signal_message : String, battler : Battler, signal_type : String) -> void:
	var damage_label = label_scene.instance()
	damage_label.initialize_status(battler, signal_type, signal_message)
	add_child(damage_label)
	damage_label.play()