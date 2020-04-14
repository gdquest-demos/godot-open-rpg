# Completes the quest upon interacting
# with the Pawn that owns this node
extends MapAction
class_name CompleteQuestAction

export var quest_reference: PackedScene
var quest: Quest = null


func _ready() -> void:
	assert(quest_reference)
	quest = QuestSystem.find_available(quest_reference.instance())
	active = false
	quest.connect("completed", self, "_on_Quest_completed")


func _on_Quest_completed() -> void:
	active = true


func interact() -> void:
	get_tree().paused = false
	if not active:
		emit_signal("finished")
		return
	QuestSystem.deliver(quest)
	active = false
	emit_signal("finished")
