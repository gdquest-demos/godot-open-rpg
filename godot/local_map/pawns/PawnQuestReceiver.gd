"""
Receives an active quest from the player and completes it.
We use this node when the quest Giver and the Receiver are two different NPCs
"""
extends PawnInteractive
class_name PawnQuestReceiver

# TODO: refactor so we don't need special scenes for NPCs that handle quests
# Every InteractivePawn should be able to start/end a quest
onready var animation_player : AnimationPlayer = $QuestBubble/AnimationPlayer
onready var quest_bubble : AnimatedSprite = $QuestBubble
onready var deliver_quest_action : = $Actions/CompleteQuestAction

func _ready() -> void:
	quest_bubble.hide()
	deliver_quest_action.connect("quest_delivered", self, "_on_quest_delivered")
	deliver_quest_action.connect("quest_finished", self, "_on_quest_finished")

func _on_quest_finished() -> void:
	quest_bubble.show()
	quest_bubble.animation = "quest_finished"
	animation_player.play("wobble")
    
func _on_quest_delivered() -> void:
    quest_bubble.hide()
    animation_player.stop()
