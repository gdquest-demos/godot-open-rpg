extends Node2D

onready var turn_queue : TurnQueue = $TurnQueue
onready var interface = $CombatInterface

var active : bool = false

func _ready():
	initialize()

func initialize():
	var battlers : Array = get_battlers()
	for battler in battlers:
		battler.initialize()
	interface.initialize(battlers)
	battle_start()

func battle_start():
	active = true
	play_turn()

func play_turn():
	var battler : Battler = get_active_battler()
	battler.selected = true
	
	var target : Battler = get_targets()[0]
	var action : CombatAction = get_active_battler().actions.get_child(0)
	yield(turn_queue.play_turn(target, action), "completed")
	
	battler.selected = false
	if active:
		play_turn()

func get_battlers() -> Array:
	return turn_queue.get_children()

func get_active_battler() -> Battler:
	return turn_queue.active_battler

func get_targets() -> Array:
	var target_group = "monster" if get_active_battler().is_in_group("party") else "party"
	var selectable_battlers : Array = []
	for battler in get_tree().get_nodes_in_group(target_group):
		if not battler.selectable:
			continue
		selectable_battlers.append(battler)
	return selectable_battlers
