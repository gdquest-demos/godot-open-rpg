extends Control

const label_scene = preload("PopupLabel.tscn")

func initialize(battlers : Array) -> void:
	for battler in battlers:
		battler.stats.connect("health_changed", self, "convert_numbers", [battler, "health"])
		battler.stats.connect("mana_changed", self, "convert_numbers", [battler, "mana"])
		for skill in battler.skills.get_children():
			skill.connect("missed", self, "spawn_label", [battler, "missed"])

func convert_numbers(new_value : int, old_value : int, battler : Battler, signal_type : String) -> void:
	var difference = str(new_value - old_value)
	spawn_label(difference, battler, signal_type)
	
func spawn_label(signal_message : String, battler : Battler, signal_type : String) -> void:
	var damage_label = label_scene.instance()
	damage_label.initialize(battler, signal_type, signal_message)
	add_child(damage_label)
	damage_label.play()