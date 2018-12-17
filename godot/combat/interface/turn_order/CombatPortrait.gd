extends Control

class_name CombatPortrait

onready var battler : Battler
onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var icon : TextureRect = $Background/Icon

func initialize(battler : Battler, play_animation : bool = true) -> void:
	battler.stats.connect('health_depleted', self, '_on_health_depleted')
	self.battler = battler
	icon.texture = battler.turn_order_icon

	# When a portrait is initialized, we must not play the reduce animaiton
	# if it corresponds to first playing battler. The highlight animation
	# will be played instead.
	if play_animation:
		reduce()

func reduce() -> void:
	"""Used as an initialization animation."""
	animation_player.play('reduce')

func highlight() -> void:
	"""Highlight the portrait.

	Used when the battler becomes active."""
	animation_player.play('highlight')

func wait() -> void:
	"""Remove the portrait highlight.

	Used when the battler switch from the active to the waiting state.
	"""
	animation_player.play('wait')

func disable() -> void:
	"""Disable (grey-out) the portrait.

	Used when the battler won't be playing anymore (dead, petrified, etc.).
	"""
	animation_player.play('disable')

func _on_health_depleted():
	disable()
