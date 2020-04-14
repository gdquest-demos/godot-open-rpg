extends Resource
class_name GrowthStats

export var level_lookup: Array = []
export var max_health_curve: Curve
export var max_mana_curve: Curve
export var strength_curve: Curve
export var defense_curve: Curve
export var speed_curve: Curve


func create_stats(experience: int) -> CharacterStats:
	# Creates and returns a CharacterStats Resource with stats
	# calculated based on the character's experience
	var stats := CharacterStats.new()
	stats.level = get_level(experience)
	stats.max_health = _get_max_health(experience)
	stats.max_mana = _get_max_mana(experience)
	stats.strength = _get_strength(experience)
	stats.defense = _get_defense(experience)
	stats.speed = _get_speed(experience)
	stats.reset()  # give stats full hp and mana on level up
	return stats


func get_level(value: int) -> int:
	var max_level: int = len(level_lookup)
	assert(max_level > 0)
	var level: int = 0
	while level + 1 < max_level && value > level_lookup[level + 1]:
		level += 1
	return level


func _get_interpolated_level(value: int = 0) -> float:
	# Calculate level, which updates all stats
	var max_level = len(level_lookup)
	assert(max_level > 0)
	var level: int = get_level(value)
	return float(level) / float(max_level)


func _get_max_health(experience: int) -> int:
	assert(max_health_curve != null)
	var level: float = _get_interpolated_level(experience)
	return int(max_health_curve.interpolate_baked(level))


func _get_max_mana(experience: int) -> int:
	assert(max_mana_curve != null)
	var level: float = _get_interpolated_level(experience)
	return int(max_mana_curve.interpolate_baked(level))


func _get_strength(experience: int) -> int:
	assert(strength_curve != null)
	var level: float = _get_interpolated_level(experience)
	return int(strength_curve.interpolate_baked(level))


func _get_defense(experience: int) -> int:
	assert(defense_curve != null)
	var level: float = _get_interpolated_level(experience)
	return int(defense_curve.interpolate_baked(level))


func _get_speed(experience: int) -> int:
	assert(speed_curve != null)
	var level: float = _get_interpolated_level(experience)
	return int(speed_curve.interpolate_baked(level))
