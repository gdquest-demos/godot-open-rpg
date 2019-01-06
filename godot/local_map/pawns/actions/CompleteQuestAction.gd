"""
Completes the quest upon interacting
with the Pawn that owns this node
"""
extends MapAction
class_name CompleteQuestAction

signal quest_delivered()

export var quest_reference : PackedScene
var quest : Quest = null

func _ready() -> void:
	assert quest_reference
	quest = QuestSystem.find_available(quest_reference.instance())

func interact() -> void:
	get_tree().paused = false
	QuestSystem.deliver(quest)
	emit_signal("quest_delivered")
	emit_signal("finished")
