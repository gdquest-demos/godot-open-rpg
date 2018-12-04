extends CharacterStats

class_name GrowthStats

var MAX_LEVEL : int = 100
var _interpolated_level : float

export(float, 0.0, 10.0) var exp_multiplier : float = 1.0
export(float, 0.1, 5.0) var exp_exponent : float = 1.8
export(float, 0.0, 100.0) var exp_level_multiplier : float = 4.0

export var max_health_curve : Curve
export var max_mana_curve : Curve
export var strength_curve : Curve
export var defense_curve : Curve
export var speed_curve : Curve

func _set_experience(value : int = 0):
	"""
	Calculate level, which updates all stats
	"""
	experience = value
	var l = level
	while l + 1 < self.MAX_LEVEL && experience > get_required_experience(l + 1):
		l += 1
	if l != level:
		level = l
		_interpolated_level =  float(level) / float(self.MAX_LEVEL)
		reset()

func get_required_experience(level : int) -> int:
	return int(round(exp_multiplier * pow(level, exp_exponent) + level * exp_level_multiplier))

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
