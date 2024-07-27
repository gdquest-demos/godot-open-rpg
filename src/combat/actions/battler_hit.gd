## Represents a damage-dealing hit to be applied to a target Battler.
## Encapsulates calculations for how hits are applied based on some properties.
class_name BattlerHit extends RefCounted

var damage: = 0
var hit_chance: = 100.0


func _init(dmg: int, to_hit := 100.0) -> void:
	damage = dmg
	hit_chance = to_hit


func is_successful() -> bool:
	return randf() * 100.0 < hit_chance
