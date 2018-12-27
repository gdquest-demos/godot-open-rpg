extends MapAction
class_name GiveQuestAction

export var quest : PackedScene

func interact() -> void:
	get_tree().paused = false
	local_map.quest_system.add_quest(quest.instance())
	emit_signal("finished")
