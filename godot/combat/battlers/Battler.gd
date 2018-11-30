extends Position2D

class_name Battler

export var TARGET_OFFSET_DISTANCE : float = 120.0
export var template : Resource

const DEFAULT_CHANCE = 0.75
var stats : CharacterStats
var drops : Array
onready var lifebar_anchor = $InterfaceAnchor
onready var skin = $Skin
onready var actions = $Actions
onready var bars = $Bars

var target_global_position : Vector2

var selected : bool = false setget set_selected
var selectable : bool = false
var display_name : String

export var party_member = false

func _ready() -> void:
	var direction : Vector2 = Vector2(-1.0, 0.0) if party_member else Vector2(1.0, 0.0)
	target_global_position = $TargetAnchor.global_position + direction * TARGET_OFFSET_DISTANCE

	var _t = template as BattlerTemplate
	actions.initialize(_t.skills)
	
	drops = _t.drops
	
	skin.add_child(_t.anim.instance())
	if stats == null:
		var starting_stats = _t.stats as CharacterStats
		stats = starting_stats.duplicate()
		stats.reset()
	stats.connect("health_depleted", self, "_on_health_depleted")
	skin.initialize()
	self.selectable = true

func set_selected(value):
	selected = value
	skin.blink = value

func attack(target : Battler):
	var hit = Hit.new(stats.strength)
	target.take_damage(hit)

func can_use_skill(skill : Skill) -> bool:
	return stats.mana >= skill.mana_cost

func use_skill(targets : Array, skill : Skill) -> void:
	if stats.mana < skill.mana_cost:
		return
	stats.mana -= skill.mana_cost
	var hit = Hit.new(stats.strength, skill.base_damage) 
	for target in targets:
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

# TODO: Move to AI-specific file
func choose_target(targets : Array) -> Array:
	"""
	This function will return a target with the following policy:
	else it will randomly choose an opponent
	Returns the target wrapped in an Array
	"""
	var this_chance = randi() % 100
	var target_min_health = targets[randi() % len(targets)]
	
	if this_chance > DEFAULT_CHANCE:
		return [target_min_health]
	
	var min_health = target_min_health.stats.health 
	for target in targets:
		if target.stats.health < min_health:
			target_min_health = target
	return [target_min_health]
