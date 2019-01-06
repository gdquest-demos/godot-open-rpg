"""
Animated exclamation and question mark that signals
an InteractivePawn can start or end a quest
"""
extends Position2D

onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	hide()
	animation_player.play("wobble")

func initialize(quest : Quest):
	quest.connect("started", self, "_on_Quest_started")
	quest.connect("completed", self, "_on_Quest_completed")
	quest.connect("delivered", self, "_on_Quest_delivered")
	show()

func _on_Quest_started():
	animated_sprite.animation = "quest_active"

func _on_Quest_completed():
	animated_sprite.animation = "quest_complete"

func _on_Quest_delivered():
	animation_player.stop()
	hide()
