extends Node

var combat_arena = preload("res://combat/CombatArena.tscn").instance()

onready var transition = $Overlays/TransitionColor
onready var local_map = get_node("LocalMap")
onready var party = $Party

var transitioning = false
func _ready():
	#enter_battle()
	local_map.connect("encounter", self, "enter_battle")
	local_map.visible = true


func enter_battle(formation_name : String):
	"""
	Plays the combat transition animation and initializes the combat scene
	"""
	if not transitioning:
		transitioning = true
		yield(transition.fade_to_color(), "completed")
		local_map.visible = false
		add_child(combat_arena)
		yield(get_tree().create_timer(0.8), "timeout")
	    combat_arena.initialize(formation, party)
		yield(transition.fade_from_color(), "completed")
		combat_arena.battle_start()
		transitioning = false
