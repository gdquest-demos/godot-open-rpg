class_name BattlerStats extends Resource

## Emitted when [member health] has reached 0.
signal health_depleted

## Emitted whenever [member health] changes.
signal health_changed(old_value, new_value)

## Emitted whenver [member energy] changes.
signal energy_changed(old_value, new_value)

@export var max_health: = 100
@export var max_energy: = 6

@export var base_attack: = 10.0:
	set(value):
		base_attack = value
		_recalculate_and_update("attack")

@export var base_defense: = 10.0:
	set(value):
		base_defense = value
		_recalculate_and_update("defense")

@export var base_speed: = 70.0:
	set(value):
		base_speed = value
		_recalculate_and_update("speed")

@export var base_hit_chance: = 100.0:
	set(value):
		base_hit_chance = value
		_recalculate_and_update("hit_chance")

@export var base_evasion: = 0.0:
	set(value):
		base_evasion = value
		_recalculate_and_update("evasion")

var health: = max_health:
	set(value):
		if value != health:
			var previous_health: = health
			health = clampi(value, 0, max_health)
			
			health_changed.emit(previous_health, health)
			if health == 0:
				health_depleted.emit()

var energy: = 0:
	set(value):
		if value != energy:
			var previous_energy = energy
			energy = clampi(value, 0, max_energy)
			
			energy_changed.emit(previous_energy, energy)
 
var attack: = base_attack
var defense: = base_defense
var speed: = base_speed
var hit_chance: = base_hit_chance
var evasion: = base_evasion


func initialize() -> void:
	health = max_health


func _recalculate_and_update(_prop_name: String) -> void:
	pass
