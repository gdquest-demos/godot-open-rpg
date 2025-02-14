## A builder class responsible for adding visual feedback to [BattlerActions].
##
## This feedback takes the form of different UI elements (such as an animated label) that may
## demonstrate how much damage was done or if an action missed the target completely.
class_name UIEffectLabelBuilder extends Node2D

@export var damage_label_scene: PackedScene
@export var missed_label_scene: PackedScene


func setup(battler_data: BattlerList) -> void:
	for battler in battler_data.get_all_battlers():

		battler.hit_missed.connect(func _on_battler_hit_missed() -> void:
			var label: = missed_label_scene.instantiate()
			add_child(label)
			label.global_position = battler.anim.top.global_position
		)

		battler.hit_received.connect(func _on_battler_hit_received(amount: int) -> void:
			var label: = damage_label_scene.instantiate() as UIDamageLabel
			add_child(label)
			label.setup(battler.anim.top.global_position, amount)
		)
