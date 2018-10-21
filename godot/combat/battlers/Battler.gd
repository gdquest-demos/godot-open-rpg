extends Position2D

class_name Battler

onready var stats : CharacterStats = $Job/Stats
onready var anchor = $InterfaceAnchor
onready var skin = $Skin
onready var actions = $Actions

var selected : bool = false setget set_selected

func play_turn(target : Battler, action : CombatAction):
	yield(skin.move_forward(), "completed")
	attack(target)
	yield(skin.move_to(target), "completed")
	yield(get_tree().create_timer(1.0), "timeout")
	yield(skin.return_to_start(), "completed")

func set_selected(value):
	selected = value
	skin.blink = value

func attack(target : Battler):
	var hit = Hit.new(stats.strength)
	target.take_damage(hit)

func take_damage(hit):
	stats.take_damage(hit)
	skin.stagger()
