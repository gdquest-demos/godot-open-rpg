extends Node
class_name QuestSystem

var active_quests = []

func add_quest(new_quest) -> void:
	if has_quest(new_quest):
		return
	add_child(new_quest)
	active_quests.append(new_quest)
	new_quest.connect("quest_finished", self, "_on_quest_finished")

func _on_quest_finished(quest) -> void:
	print("Quest finished -> Give rewards")
	assert quest in active_quests
	var quest_index = active_quests.find(quest)
	active_quests[quest_index].queue_free()
	active_quests.remove(quest_index)

func _on_Game_combat_started() -> void:
	for quest in active_quests:
		(quest as Quest).notify_slay_objectives()

func has_quest(quest) -> bool:
	for active_quest in active_quests:
		if active_quest.title == quest.title:
			return true
	return false
