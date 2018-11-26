extends YSort

class_name TurnQueue

onready var active_battler : Battler

func initialize():
	var battlers = get_battlers()
	battlers.sort_custom(self, 'sort_battlers')
	for battler in battlers:
		battler.raise()
	active_battler = get_child(0)

func play_turn(action : CombatAction):
	yield(active_battler.skin.move_forward(), "completed")
	if active_battler.party_member:
		action.initialize(get_monsters(), get_party(), active_battler)
	else:
		action.initialize(get_party(), get_monsters(), active_battler)
	yield(action.execute(), "completed")
	var target = action.target
	if target != null:
		var new_index : int = (active_battler.get_index() + 1) % get_child_count()
		active_battler = get_child(new_index)

func skip_turn():
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
		if child.party_member == in_party && child.stats.health > 0:
			targets.append(child)
	return targets

func get_battlers():
	return get_children()
