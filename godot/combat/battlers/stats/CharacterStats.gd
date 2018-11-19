extends Node

class_name CharacterStats

signal health_changed(new_health)
signal health_depleted()

var modifiers = {}

var health : int
var mana : int
var max_health : int setget set_max_health
var max_mana : int setget set_max_mana
var strength : int
var defense : int
var speed : int

func initialize(stats : StartingStats):
	max_health = stats.max_health
	max_mana = stats.max_mana
	strength = stats.strength
	defense = stats.defense
	speed = stats.speed
	health = max_health
	mana = max_mana

func set_max_health(value):
	max_health = max(0, value)

func set_max_mana(value):
	max_mana = max(0, value)

func take_damage(hit):
	health -= hit.damage
	health = max(0, health)
	emit_signal("health_changed", health)
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
