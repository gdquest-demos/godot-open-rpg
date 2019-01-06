extends MapAction
class_name GiveQuestAction

signal quest_given(quest)

export var quest_scene : PackedScene

func _ready() -> void:
	assert quest_scene

func interact() -> void:
	get_tree().paused = false
	var quest : Quest = quest_scene.instance()
	if not QuestSystem.is_available(quest):
		return
	QuestSystem.start(quest)
	emit_signal("quest_given", quest)
	emit_signal("finished")
