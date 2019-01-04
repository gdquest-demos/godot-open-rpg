extends MapAction
class_name GiveQuestAction

signal quest_given(quest)

export var quest : PackedScene

func interact() -> void:
	get_tree().paused = false
	var quest_instance = quest.instance()
	if not local_map.quest_system.has_quest(quest_instance):
		emit_signal("quest_given", quest_instance)
		local_map.quest_system.add_quest(quest_instance)
	emit_signal("finished")
