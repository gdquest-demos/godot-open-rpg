extends Node

signal combat_started()
signal combat_finished()

const combat_arena_scene = preload("res://combat/CombatArena.tscn")
onready var transition = $Overlays/TransitionColor
onready var local_map = $LocalMap
onready var party = $Party as Party
onready var music_player = $MusicPlayer

var transitioning = false
var ongoing_combat

func _ready():
	local_map.visible = true
	local_map.spawn_party(party)

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
	ongoing_combat = combat_arena_scene.instance()
	add_child(ongoing_combat)
	ongoing_combat.connect("victory", self, "_on_CombatArena_player_victory")
	ongoing_combat.connect("combat_restarted", self, "_on_combat_restarted")
	ongoing_combat.initialize(formation, party.get_active_members())
	yield(transition.fade_from_color(), "completed")
	transitioning = false
	ongoing_combat.battle_start()
	
	# Get data from the battlers after the battle ended,
	# Then copy into the Party node to save earned experience,
	# items, and currentstats
	var updates = yield(ongoing_combat, "battle_ended")
	party.update_members(updates)

	emit_signal("combat_finished")
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	ongoing_combat.queue_free()
	add_child(local_map)
	yield(transition.fade_from_color(), "completed")
	transitioning = false
	music_player.stop()

func _on_CombatArena_player_victory():
	music_player.play_victory_fanfare()

func _on_combat_restarted(formation : Formation) -> void:
	ongoing_combat.queue_free()
	enter_battle(formation)
