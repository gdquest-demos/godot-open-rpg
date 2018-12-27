"""
Base entity that represents a character or a monster in combat
Every battler has an AI node so all characters can work as a monster
or as a computer-controlled player ally
"""
extends Position2D

class_name Battler

export var TARGET_OFFSET_DISTANCE : float = 120.0

export var stats : Resource
var drops : Array
onready var skin = $Skin
onready var actions = $Actions
onready var bars = $Bars
onready var skills = $Skills
onready var ai = $AI

var target_global_position : Vector2

var selected : bool = false setget set_selected
var selectable : bool = false
var display_name : String

export var party_member = false
export var turn_order_icon : Texture

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

func is_able_to_play() -> bool:
	"""
	Returns true if the battler can perform an action
	Currently it only checks that the battler is alive,
	but we should use this method later to check its current status as well
	"""
	return stats.health > 0

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

func appear():
	var offset_direction = 1.0 if party_member else -1.0
	skin.position.x += TARGET_OFFSET_DISTANCE * offset_direction
	skin.appear()

func has_point(point : Vector2):
	return skin.battler_anim.extents.has_point(point)
