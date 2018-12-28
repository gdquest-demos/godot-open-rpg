extends QuestObjective
class_name QuestSlayObjective

export var amount : int
export var battler_to_slay : PackedScene

func connect_signals() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.connect("died", self, "_on_enemy_died")

func _on_enemy_died(battler) -> void:
	if battler.filename == battler_to_slay.resource_path:
		amount -= 1
		if amount == 0 and not finished:
			finish()
