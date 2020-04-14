# Starts a quest upon interacting with the InteractivePawn
extends MapAction
class_name GiveQuestAction

export var quest_reference: PackedScene
var quest: Quest = null


func _ready() -> void:
	assert(quest_reference)
	quest = QuestSystem.find_available(quest_reference.instance())
	quest.connect("started", self, "_on_Quest_started")


func _on_Quest_started():
	active = false


func interact() -> void:
	get_tree().paused = false
	if not active:
		emit_signal("finished")
		return
	var quest: Quest = quest_reference.instance()
	if not QuestSystem.is_available(quest):
		return
	QuestSystem.start(quest)
	emit_signal("finished")
