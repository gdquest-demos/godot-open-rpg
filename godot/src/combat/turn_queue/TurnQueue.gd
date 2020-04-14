extends YSort

class_name TurnQueue

signal queue_changed

onready var active_battler: Battler
var last_action_canceled: bool = false


func initialize():
	var battlers = get_battlers()
	battlers.sort_custom(self, 'sort_battlers')
	for battler in battlers:
		battler.raise()
	active_battler = get_child(0)
	emit_signal('queue_changed', get_battlers(), active_battler)


func play_turn(action: CombatAction, targets: Array):
	if not last_action_canceled:
		yield(active_battler.skin.move_forward(), "completed")
	action.initialize(active_battler)
	var hit_target = yield(action.execute(targets), "completed")
	if not hit_target:
		last_action_canceled = true
		return
	last_action_canceled = false
	_next_battler()


func skip_turn():
	_next_battler()


func _next_battler():
	var next_battler_index: int = (active_battler.get_index() + 1) % get_child_count()
	active_battler = get_child(next_battler_index)
	emit_signal('queue_changed', get_battlers(), active_battler)


static func sort_battlers(a: Battler, b: Battler) -> bool:
	return a.stats.speed > b.stats.speed


func get_party():
	return _get_targets(true)


func get_monsters():
	return _get_targets(false)


func _get_targets(in_party: bool = false) -> Array:
	var targets: Array = []
	for child in get_children():
		if child.party_member == in_party && child.stats.health > 0:
			targets.append(child)
	return targets


func get_battlers():
	return get_children()


func print_queue():
	# Prints the Battlers' and their speed in the turn order
	var string: String
	for battler in get_children():
		string += battler.name + "(%s)" % battler.stats.speed + " "
	print(string)
