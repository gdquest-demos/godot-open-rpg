extends Position2D

class_name Battler

export var TARGET_OFFSET_DISTANCE : float = 120.0

const DEFAULT_CHANCE = 0.75
onready var stats : CharacterStats = $Job/Stats
onready var lifebar_anchor = $InterfaceAnchor
onready var skin = $Skin
onready var actions = $Actions

var target_global_position : Vector2

var selected : bool = false setget set_selected
var selectable : bool = false

export var party_member = false

func _ready() -> void:
	var direction : Vector2 = Vector2(-1.0, 0.0) if party_member else Vector2(1.0, 0.0)
	target_global_position = $TargetAnchor.global_position + direction * TARGET_OFFSET_DISTANCE
	
	stats.connect("health_depleted", self, "_on_health_depleted")
	self.selectable = true

func play_turn(target : Battler, action):
	yield(skin.move_forward(), "completed")
	action.execute(self, target)
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
	skin.play_stagger()

func _on_health_depleted():
	selectable = false
	yield(skin.play_death(), "completed")
	queue_free()

func appear():
	var offset_direction = 1.0 if party_member else -1.0
	skin.position.x += TARGET_OFFSET_DISTANCE * offset_direction
	skin.appear()

func choose_target(targets : Array):
	"""
	This function will return a target with the following policy:
	There is a chance of DEFAULT_CHANCE to target the foe with min health
	else it will randomly choose an opponent
	"""
	var this_chance = randi() % 100
	var target_min_health = targets[randi() % len(targets)]
	
	if this_chance > DEFAULT_CHANCE:
		return target_min_health
	
	var min_health = target_min_health.stats.health 
	for target in targets:
		if target.stats.health < min_health:
			target_min_health = target
	return target_min_health