extends Resource
class_name MonsterDrops

"""
While we still can't export custom types, we'll have to use an Array of dictionaries
Example:
	{
		'item': Sword.tres,
		'min_quantity': 1,
		'max_quantity': 1,
		'chance': 0.5
	}, {
		'item': Potion.tres,
		'min_quantity': 3,
		'max_quantity': 20,
		'chance': 0.25
	}, 
"""

export var items : Array
