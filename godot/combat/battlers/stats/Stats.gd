extends Node

class_name CharacterStats

signal health_changed(amount)
signal health_depleted()

var modifiers = {}

var health : int = 0
export var max_health : int = 9 setget set_max_health
export var strength : int = 2
export var defense : int = 0

func _ready():
	health = max_health

func set_max_health(value):
	max_health = max(0, value)

func take_damage(hit):
	health -= hit.damage
	health = max(0, health)
	emit_signal("health_changed", hit.damage)
	if health == 0:
		emit_signal("health_depleted")

func heal(amount):
	health += amount
	health = max(health, max_health)
	emit_signal("health_changed", amount)

func add_modifier(id, modifier):
	modifiers[id] = modifier

func remove_modifier(id):
	modifiers.erase(id)
