"""
Starts a quest upon interacting with the InteractivePawn
"""
extends MapAction
class_name GiveQuestAction

signal quest_given()

export var quest_reference : PackedScene
var quest : Quest = null

func _ready() -> void:
	assert quest_reference
	quest = QuestSystem.find_available(quest_reference.instance())

func interact() -> void:
	get_tree().paused = false
	var quest : Quest = quest_reference.instance()
	if not QuestSystem.is_available(quest):
		return
	QuestSystem.start(quest)
	emit_signal("quest_given")
	emit_signal("finished")
