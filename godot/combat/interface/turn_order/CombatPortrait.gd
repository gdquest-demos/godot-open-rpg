extends Control

class_name CombatPortrait

onready var battler : Battler
onready var animation_player : AnimationPlayer = $AnimationPlayer

func initialize(battler : Battler) -> void:
	self.battler = battler

func reduce() -> void:
	animation_player.play('reduce')

func highlight() -> void:
	animation_player.play('highlight')

func wait() -> void:
	animation_player.play('wait')

func disable() -> void:
	animation_player.play('disable')
