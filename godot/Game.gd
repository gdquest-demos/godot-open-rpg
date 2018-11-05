extends Node

onready var combat_arena = $CombatArena
onready var transition = $Overlays/TransitionColor

func _ready():
	enter_battle()

func enter_battle():
	"""
	Plays the combat transition animation and initializes the combat scene
	"""
	yield(transition.fade_to_color(), "completed")
	combat_arena.initialize()
	yield(get_tree().create_timer(0.8), "timeout")
	yield(transition.fade_from_color(), "completed")
	combat_arena.battle_start()
