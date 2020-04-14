extends Resource

class_name BattlerTemplate

export var anim: PackedScene
export var stats: Resource
export var skills: Array

# For drops, we're currently using an Array of dictionaries
# Example:
# {
# 'item': Sword.tres,
# 'min_amount': 1,
# 'max_amount': 1,
# 'chance': 0.5
# }, {
# 'item': Potion.tres,
# 'min_amount': 3,
# 'max_amount': 20,
# 'chance': 0.25
# }, 
export var drops: Array
