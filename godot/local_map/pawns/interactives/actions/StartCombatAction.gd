extends MapAction
class_name StartCombatAction

export var map_path : NodePath
export var formation : PackedScene

onready var local_map : = get_node(map_path) as LocalMap

func interact() -> void:
	local_map.start_encounter(formation)
	yield(local_map, "combat_finished")
	emit_signal("finished")