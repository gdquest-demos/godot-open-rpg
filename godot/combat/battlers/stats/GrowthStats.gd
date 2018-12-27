"""
Uses curves and lookup tables to calculate a battler's stats

"""
extends CharacterStats

class_name GrowthStats

# level as a percentage of the max_level, in the [0.0, 1.0] range
var _interpolated_level : float

export var level_lookup : Array = []
export var max_health_curve : Curve
export var max_mana_curve : Curve
export var strength_curve : Curve
export var defense_curve : Curve
export var speed_curve : Curve

func _set_experience(value : int = 0):
	"""
	Calculate level, which updates all stats
	"""
	var max_level = len(level_lookup)
	experience = max(0, value)
	var l = level
	while l + 1 < max_level && experience > level_lookup[l+1]:
		l += 1
	if l != level:
		level = l
		_interpolated_level = float(level) / float(max_level)
		reset()

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
