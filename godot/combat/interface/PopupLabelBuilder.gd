extends Control

const label_scene = preload("PopupLabel.tscn")

func initialize(battlers : Array) -> void:
	for battler in battlers:
		battler.stats.connect("health_changed", self, "spawn_label", [battler, "health"])
		battler.stats.connect("mana_changed", self, "spawn_label", [battler, "mana"])

func spawn_label(new_value : int, old_value : int, battler : Battler, signal_type : String) -> void:
	var difference = new_value - old_value
	var damage_label = label_scene.instance()
	damage_label.initialize(battler, signal_type, difference)
	add_child(damage_label)
	damage_label.play()
