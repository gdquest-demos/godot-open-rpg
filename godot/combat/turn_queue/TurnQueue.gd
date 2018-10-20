extends YSort

signal turn_started(battler)

onready var active_battler : Battler = $Battler

func play_turn():
	emit_signal('turn_started', active_battler)
	yield(active_battler, 'turn_finished')
	var new_index : int = (active_battler.get_index() + 1) % get_child_count()
	active_battler = get_child(new_index)
	play_turn()
