extends YSort

class_name TurnQueue

onready var active_battler : Battler

func _ready():
	initialize()

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
