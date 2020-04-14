# Base object that represents an attack or a hit

class_name Hit

var damage = 0
# var effect : StatusEffect = StatusEffect.new()


func _init(strength: int, additional_damage: int = 0) -> void:
	damage = strength + additional_damage
