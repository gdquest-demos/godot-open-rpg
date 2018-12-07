extends MapAction
class_name StartCombatAction

export var formation : PackedScene

func interact() -> void:
	local_map.start_encounter(formation)
	yield(local_map, "combat_finished")
	emit_signal("finished")
