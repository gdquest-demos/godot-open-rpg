extends Item
class_name Equipment

enum Slot { Weapon, Armor, Accessory }

export (Slot) var slot = Slot.Weapon

# stat boosts provided when equipped
export (Resource) var stats = null setget , _get_stats


func _get_stats() -> CharacterStats:
	# TODO figure out a way to stack these stats onto battlers,
	# will probably require creating a new stats class for equipment
	return stats
