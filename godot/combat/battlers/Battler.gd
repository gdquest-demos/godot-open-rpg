extends Position2D

class_name Battler

onready var health : CharacterStats = $Job/Stats
onready var anchor = $InterfaceAnchor
onready var skin = $Skin

func take_damage(hit):
	health.take_damage(hit)

func play_turn():
	yield(skin.move_forward(), "completed")
	yield(get_tree().create_timer(0.6), "timeout")
	yield(skin.return_to_start(), "completed")
