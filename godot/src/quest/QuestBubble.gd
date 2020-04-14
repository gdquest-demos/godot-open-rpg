# Animated exclamation and question mark that signals
# an InteractivePawn can start or end a quest
extends Position2D

onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	hide()
	animation_player.play("wobble")


func initialize(quest_actions: Array):
	var quest = quest_actions[0].quest
	var name = get_parent().name
	var action_give: GiveQuestAction
	var action_complete: CompleteQuestAction
	for action in quest_actions:
		if action is GiveQuestAction:
			action_give = action
		if action is CompleteQuestAction:
			action_complete = action

	if action_give:
		quest.connect("started", self, "_on_Quest_started")
		if not action_complete:
			quest.connect("completed", self, "hide")
		show()
	if action_complete:
		quest.connect("completed", self, "_on_Quest_completed")
		quest.connect("delivered", self, "_on_Quest_delivered")


func _on_Quest_started():
	animated_sprite.animation = "quest_active"


func _on_Quest_completed():
	show()
	animated_sprite.animation = "quest_complete"


func _on_Quest_delivered():
	animation_player.stop()
	hide()
