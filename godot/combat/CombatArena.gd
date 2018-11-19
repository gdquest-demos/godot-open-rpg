extends Node2D

onready var turn_queue : TurnQueue = $TurnQueue
onready var interface = $CombatInterface

var active : bool = false

func initialize():
	var battlers = turn_queue.get_battlers()
	interface.initialize(battlers)
	turn_queue.initialize()

func battle_start():
	active = true
	yield(play_intro(), "completed")
	play_turn()

func play_intro():
	# Play the appear animation on all battlers in cascade
	for battler in turn_queue.get_party():
		battler.appear()
		yield(get_tree().create_timer(0.15), "timeout")
	yield(get_tree().create_timer(0.8), "timeout")
	for battler in turn_queue.get_monsters():
		battler.appear()
		yield(get_tree().create_timer(0.15), "timeout")
	yield(get_tree().create_timer(0.8), "timeout")

func battle_end():
	active = false
	var player_lost = get_active_battler().party_member
	print('Player lost: %s' % player_lost)

func play_turn():
	var battler : Battler = get_active_battler()
	battler.selected = true
	
	var targets : Array = get_targets()
	if not targets:
		battle_end()
		return
	var target : Battler
	var action : CombatAction
	if battler.party_member:
		interface.update_actions(battler)
		target = yield(interface.select_target(targets), "completed")
#		action = get_active_battler().actions.get_child(0)
		action = interface.selected_action
	else:
		# Temp random target selection for the monsters
		target = battler.choose_target(targets)
		action = get_active_battler().actions.get_child(0)

	yield(turn_queue.play_turn(target, action), "completed")
	
	battler.selected = false
	if active:
		play_turn()

func get_active_battler() -> Battler:
	return turn_queue.active_battler

func get_targets() -> Array:
	if get_active_battler().party_member:
		return turn_queue.get_monsters()
	else:
		return turn_queue.get_party()
