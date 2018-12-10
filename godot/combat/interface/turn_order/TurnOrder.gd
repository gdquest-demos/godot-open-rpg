extends Control

onready var active_battler_index : int = -1 setget _set_active_battler_index

onready var portraits = $CombatPortraits
var CombatPortrait = preload("res://combat/interface/turn_order/CombatPortrait.tscn")

func initialize(battlers : Array) -> void:
	"""Creates the turn order interface.
	
	For each battler, both PC and NPC, create its interactive portrait and add 
	it to the portraits list.
	"""
	for battler in battlers:
		var new_portrait : CombatPortrait = CombatPortrait.instance()
		portraits.add_child(new_portrait)
		new_portrait.initialize()

func next() -> void:
	"""Switch to the next battler.
	
	Deactivate the previous portrait and activate the next one.
	"""
	if active_battler_index != -1:
		portraits.get_children()[active_battler_index].wait()

	# use 'self' to trigger the setter method to prevent index error
	self.active_battler_index += 1
	portraits.get_children()[active_battler_index].activate()

func disable_portrait(index) -> void:
	"""Used when a battler dies."""
	portraits.get_children()[index].disable()

func _set_active_battler_index(value):
	if value >= portraits.get_child_count():
		value = 0
	active_battler_index = value
