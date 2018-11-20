extends Resource

class_name StartingStats

export var job_name : String = "Job"

export var max_health : int setget ,_get_max_health
export var max_mana : int setget ,_get_max_mana
export var strength : int setget ,_get_strength
export var defense : int setget ,_get_defense
export var speed : int setget ,_get_speed
export var experience : int setget _set_experience, _get_experience
var level : int = 0 setget ,_get_level

func _get_max_health() -> int:
	return max_health

func _get_max_mana() -> int:
	return max_mana

func _get_strength() -> int:
	return strength
	
func _get_defense() -> int:
	return defense
	
func _get_speed() -> int:
	return speed

func _get_experience() -> int:
	return experience

func _set_experience(value):
	if value == null or value < 0:
		value = 0
	experience = value

func _get_level() -> int:
	return level
