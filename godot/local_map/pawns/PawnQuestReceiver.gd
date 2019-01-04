extends "res://local_map/pawns/QuestPawn.gd"
class_name PawnQuestReceiver

onready var deliver_quest_action : = $Actions/DeliverQuestAction

func _ready() -> void:
	quest_bubble.hide()
	deliver_quest_action.connect("quest_delivered", self, "_on_quest_delivered")
	deliver_quest_action.connect("quest_finished", self, "_on_quest_finished")

func _on_quest_finished() -> void:
	quest_bubble.show()
	quest_bubble.texture = QUEST_FINISHED_TEXTURE
	animation_player.play("wobble")
    
func _on_quest_delivered() -> void:
    quest_bubble.hide()
    animation_player.stop()
