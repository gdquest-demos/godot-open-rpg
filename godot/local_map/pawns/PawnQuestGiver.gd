extends "res://local_map/pawns/QuestPawn.gd"
class_name PawnQuestGiver

func _ready() -> void:
	animation_player.play("wobble")
	for action in actions.get_children():
		if action is GiveQuestAction:
			action.connect("quest_given", self, "_on_quest_given")
			break

func _on_quest_given(quest : Quest) -> void:
	quest.connect("quest_finished", self, "_on_quest_finished")
	quest.connect("quest_delivered", self, "_on_quest_delivered")
	quest_bubble.texture = QUEST_ACTIVE_TEXTURE

func _on_quest_finished(quest : Quest) -> void:
	if quest.has_to_be_delivered:
		for action in actions.get_children():
			if action is DeliverQuestAction:
				quest_bubble.texture = QUEST_FINISHED_TEXTURE

func _on_quest_delivered() -> void:
	animation_player.stop()
	quest_bubble.hide()
