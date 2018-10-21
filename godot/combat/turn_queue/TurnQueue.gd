extends YSort

class_name TurnQueue

onready var active_battler : Battler = get_child(0)

func play_turn():
	yield(active_battler.play_turn(), "completed")
	var new_index : int = (active_battler.get_index() + 1) % get_child_count()
	active_battler = get_child(new_index)
