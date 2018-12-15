extends Position2D

class_name Battler

export var TARGET_OFFSET_DISTANCE : float = 120.0

const DEFAULT_CHANCE = 0.75
export var stats : Resource
var drops : Array
onready var skin = $Skin
onready var actions = $Actions
onready var bars = $Bars
onready var skills = $Skills

var target_global_position : Vector2

var selected : bool = false setget set_selected
var selectable : bool = false
var display_name : String

export var party_member = false

func _ready() -> void:
	var direction : Vector2 = Vector2(-1.0, 0.0) if party_member else Vector2(1.0, 0.0)
	target_global_position = $TargetAnchor.global_position + direction * TARGET_OFFSET_DISTANCE
	stats = (stats as CharacterStats).copy()
	drops = $Drops.get_children()
	self.selectable = true
	
func initialize():
	skin.initialize()
	actions.initialize(skills.get_children())
	stats.connect("health_depleted", self, "_on_health_depleted")

func set_selected(value):
	selected = value
	skin.blink = value

func take_damage(hit):
	stats.take_damage(hit)

	# prevent playing both stagger and death animation if health <= 0
	if stats.health > 0:
		skin.play_stagger()

func _on_health_depleted():
	selectable = false
	yield(skin.play_death(), "completed")
	queue_free()

func appear():
	var offset_direction = 1.0 if party_member else -1.0
	skin.position.x += TARGET_OFFSET_DISTANCE * offset_direction
	skin.appear()

func has_point(point : Vector2):
	return skin.battler_anim.extents.has_point(point)

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
