extends Control

const PopupLabel := preload("PopupLabel.tscn")


func initialize(battlers: Array) -> void:
	for battler in battlers:
		battler.stats.connect("health_changed", self, "spawn_label_number", [battler, "health"])
		battler.stats.connect("mana_changed", self, "spawn_label_number", [battler, "mana"])
		for skill in battler.skills.get_children():
			skill.connect("missed", self, "spawn_label", [battler, "missed"])


func spawn_label_number(new_value: int, old_value: int, battler: Battler, type: String) -> void:
	# Spawns a damage or a mana cost animated label
	# Converts a difference to a string and delegates to spawn_label
	var message := str(new_value - old_value)
	spawn_label(message, battler, type)


func spawn_label(message: String, battler: Battler, type: String) -> void:
	# Spawns an animated PopupLabel
	var l := PopupLabel.instance()
	add_child(l)
	l.start(battler, type, message)
