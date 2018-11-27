extends Node

const combat_arena_scene = preload("res://combat/CombatArena.tscn")
onready var transition = $Overlays/TransitionColor
onready var local_map = $LocalMap
onready var party = $Party as Party

var transitioning = false

func _ready():
	#enter_battle()
	local_map.connect("encounter", self, "enter_battle")
	local_map.visible = true

func enter_battle(formation: Formation):
	"""
	Plays the combat transition animation and initializes the combat scene
	"""
	if transitioning:
		return
		
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	remove_child(local_map)
	var combat_arena = combat_arena_scene.instance()
	add_child(combat_arena)
	combat_arena.initialize(formation, party.get_active_members())
	yield(transition.fade_from_color(), "completed")
	transitioning = false
	combat_arena.battle_start()
	# persist character status updates after combat is complete
	var updates = yield(combat_arena, "completed")
	party.update_members(updates)
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	combat_arena.queue_free()
	add_child(local_map)
	yield(transition.fade_from_color(), "completed")
	transitioning = false