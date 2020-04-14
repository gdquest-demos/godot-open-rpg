extends MapAction
class_name StartCombatAction

export var formation: PackedScene


func interact() -> void:
	get_tree().paused = false
	local_map.start_encounter(formation)
	emit_signal("finished")
