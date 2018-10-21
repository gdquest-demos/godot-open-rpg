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

func get_battlers():
	var battlers = turn_queue.get_children()
	battlers.sort_custom(self, "sort_battlers_by_initiative")
	return battlers

func get_active_battler():
	return turn_queue.active_battler

func get_targets():
	var target_group = "monster" if get_active_battler().is_in_group("party") else "party"
	return get_tree().get_nodes_in_group(target_group)
