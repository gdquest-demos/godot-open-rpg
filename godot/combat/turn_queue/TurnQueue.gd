extends YSort

class_name TurnQueue

onready var active_battler : Battler

func initialize():
	var battlers = get_children()
	battlers.sort_custom(self, 'sort_battlers')
	for battler in battlers:
		battler.raise()
	active_battler = get_child(0)

func play_turn(target : Battler, action : CombatAction):
	yield(active_battler.play_turn(target, action), "completed")
	var new_index : int = (active_battler.get_index() + 1) % get_child_count()
	active_battler = get_child(new_index)

static func sort_battlers(a : Battler, b : Battler) -> bool:
	return a.stats.speed > b.stats.speed

func print_queue():
	"""Prints the Battlers' and their speed in the turn order"""
	var string : String
	for battler in get_children():
		string += battler.name + "(%s)" % battler.stats.speed + " "
	print(string)

func get_party():
	return _get_targets(true)

func get_monsters():
	return _get_targets(false)

func _get_targets(in_party : bool = false) -> Array:
	var targets : Array = []
	for child in get_children():
		if child.party_member == in_party:
			print("%s is party member: %s" % [child.name, child.party_member])
			targets.append(child)
	return targets
