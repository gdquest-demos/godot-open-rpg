"""
Gives a quest to the player. Displays a bubble that shows that a quest is available.
"""
# TODO: After giving some more thought, if possible I'd rather avoid 
# having specialized scenes for NPCs to give and receive quests
# The action should be enough, and quest_bubble should connect to
# the quest by itself if possible 
extends PawnInteractive
class_name PawnQuestGiver

onready var animation_player : AnimationPlayer = $QuestBubble/AnimationPlayer
onready var quest_bubble : AnimatedSprite = $QuestBubble
onready var actions : = $Actions

func _ready() -> void:
	animation_player.play("wobble")
	for action in actions.get_children():
		if not action is GiveQuestAction:
			continue
		action.connect("quest_given", self, "_on_quest_given")
		break

func _on_quest_given(quest : Quest) -> void:
	quest.connect("quest_finished", self, "_on_quest_finished")
	quest.connect("quest_delivered", self, "_on_quest_delivered")
	quest_bubble.animation = "quest_active"

func _on_quest_finished(quest : Quest) -> void:
	assert quest.has_to_be_delivered
	for action in actions.get_children():
		if not action is CompleteQuestAction:
			continue
		quest_bubble.animation = "quest_finished"

func _on_quest_delivered() -> void:
	animation_player.stop()
	quest_bubble.hide()
