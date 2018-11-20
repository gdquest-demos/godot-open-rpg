extends StartingStats

class_name GrowthStats

var MAX_LEVEL : int setget ,_get_max_level
var _interpolated_level : float
export var experience_curve : Array
export var max_health_curve : Curve
export var max_mana_curve : Curve
export var strength_curve : Curve
export var defense_curve : Curve
export var speed_curve : Curve

func _get_max_level() -> int:
	return len(experience_curve)
	
func _get_interpolated_level() -> float:
	return float(level) / float(self.MAX_LEVEL)

func _set_experience(value : int = 0):
	"""
	Calculate level, which updates all stats
	"""
	experience = value
	var l = level
	while l + 1 < self.MAX_LEVEL && experience > experience_curve[l + 1]:
		l += 1
	level = l
	_interpolated_level =  float(level) / float(self.MAX_LEVEL)

func _get_max_health() -> int:
	return int(max_health_curve.interpolate_baked(_interpolated_level))

func _get_max_mana() -> int:
	return int(max_mana_curve.interpolate_baked(_interpolated_level))

func _get_strength() -> int:
	return int(strength_curve.interpolate_baked(_interpolated_level))

func _get_defense() -> int:
	return int(defense_curve.interpolate_baked(_interpolated_level))

func _get_speed() -> int:
	return int(speed_curve.interpolate_baked(_interpolated_level))
