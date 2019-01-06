"""
Completes the quest stored in the quest_scene variable
upon interacting with the Pawn that owns this node
"""
extends MapAction
class_name CompleteQuestAction

export var quest_scene : PackedScene

func _ready() -> void:
	assert quest_scene

func interact() -> void:
	get_tree().paused = false
	QuestSystem.deliver(quest_scene.instance())
	emit_signal("finished")
