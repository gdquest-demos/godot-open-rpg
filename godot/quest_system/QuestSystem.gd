extends Node
class_name QuestSystem

var quests = []

func add_quest(new_quest) -> void:
	add_child(new_quest)
	quests.append(new_quest)
	new_quest.connect("quest_finished", self, "_on_quest_finished")

func _on_quest_finished(quest) -> void:
	print("Quest finished -> Give rewards")

func _on_Game_combat_started() -> void:
	for quest in quests:
		(quest as Quest).notify_slay_objectives()

func has_quest(other_quest) -> bool:
	for quest in quests:
		if quest.title == other_quest.title:
			return true
	return false
