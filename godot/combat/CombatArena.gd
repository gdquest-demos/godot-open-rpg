extends Node2D

onready var turn_queue : TurnQueue = $TurnQueue
onready var interface = $CombatInterface

var active : bool = false

func _ready():
	initialize()

func initialize():
	interface.initialize(get_battlers())
	active = true
	play_turn()

func play_turn():
	yield(turn_queue.play_turn(), "completed")
	if active:
		play_turn()

func get_battlers():
	return turn_queue.get_children()
