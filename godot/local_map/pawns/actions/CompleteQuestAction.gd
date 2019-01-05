"""
Completes the quest stored in the quest_scene variable
upon interacting with the Pawn that owns this node
"""
extends MapAction
class_name CompleteQuestAction

signal quest_delivered()
signal quest_finished()

export var quest_scene : PackedScene
var quest : Quest = null

func initialize(_local_map) -> void:
	assert quest_scene
	.initialize(_local_map)
	yield(get_tree(), "idle_frame")
	local_map.quest_system.connect("quest_finished", self, "_on_quest_finished")
	quest = quest_scene.instance()

func _on_quest_finished(_quest : Quest) -> void:
	assert quest.title == _quest.title
	emit_signal("quest_finished")

func interact() -> void:
	get_tree().paused = false
	assert local_map.quest_system.has_quest(quest)
	# TODO: isn't there a way to simplify this? We're getting the instance of the quest
	# from the QuestSystem passing our quest obj. as a reference
	# Then the quest delivers itself... it's not an intuitive API
	var finished_quest = local_map.quest_system.get_finished_quest(quest)
	if finished_quest:
		finished_quest.deliver_quest()
		local_map.quest_system.reward_player(finished_quest)
		emit_signal("quest_delivered")
	emit_signal("finished")
