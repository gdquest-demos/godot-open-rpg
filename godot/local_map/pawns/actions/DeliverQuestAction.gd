extends MapAction
class_name DeliverQuestAction

signal quest_delivered()
signal quest_finished()

export var quest : PackedScene

func initialize(map) -> void:
	.initialize(map)
	yield(get_tree(), "idle_frame")
	local_map.quest_system.connect("quest_finished", self, "_on_quest_finished")

func _on_quest_finished(quest : Quest) -> void:
	if quest.title == self.quest.instance().title:
		emit_signal("quest_finished")

func interact() -> void:
	get_tree().paused = false
	var quest_instance = quest.instance()
	if local_map.quest_system.has_quest(quest_instance):
		var finished_quest = local_map.quest_system.get_finished_quest(quest_instance)
		if finished_quest != null:
			finished_quest.deliver_quest()
			local_map.quest_system.reward_player(finished_quest)
			emit_signal("quest_delivered")
	emit_signal("finished")
