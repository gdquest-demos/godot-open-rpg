extends MapAction
class_name DeliverQuestAction

export var quest : PackedScene

func interact() -> void:
	get_tree().paused = false
	var quest_instance = quest.instance()
	if local_map.quest_system.has_quest(quest_instance):
		var finished_quest = local_map.quest_system.get_finished_quest(quest_instance)
		if finished_quest != null:
			finished_quest.deliver_quest()
			local_map.quest_system.reward_player(finished_quest)
	emit_signal("finished")
