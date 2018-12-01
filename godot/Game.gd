extends Node

signal combat_started()
signal combat_finished()

const combat_arena_scene = preload("res://combat/CombatArena.tscn")
onready var transition = $Overlays/TransitionColor
onready var local_map = $LocalMap
onready var party = $Party as Party
onready var music_player = $MusicPlayer

var transitioning = false

func _ready():
	local_map.visible = true

func enter_battle(formation: Formation):
	"""
	Plays the combat transition animation and initializes the combat scene
	"""
	if transitioning:
		return
		
	emit_signal("combat_started")
	music_player.play_battle_theme()
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	remove_child(local_map)
	var combat_arena = combat_arena_scene.instance()
	add_child(combat_arena)
	combat_arena.connect("victory", self, "_on_CombatArena_player_victory")
	combat_arena.initialize(formation, party.get_active_members())
	yield(transition.fade_from_color(), "completed")
	transitioning = false
	combat_arena.battle_start()
	
	# Get data from the battlers after the battle ended,
	# Then copy into the Party node to save earned experience,
	# items, and currentstats
	var updates = yield(combat_arena, "battle_ended")
	party.update_members(updates)

	emit_signal("combat_finished")
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	combat_arena.queue_free()
	add_child(local_map)
	yield(transition.fade_from_color(), "completed")
	transitioning = false
	music_player.stop()

func _on_CombatArena_player_victory():
	music_player.play_victory_fanfare()
