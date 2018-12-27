extends Node

signal combat_started()
signal combat_finished()

const combat_arena_scene = preload("res://combat/CombatArena.tscn")
onready var transition = $Overlays/TransitionColor
onready var local_map = $LocalMap
onready var party = $Party as Party
onready var music_player = $MusicPlayer
onready var game_over_interface : = $GameOverInterface
onready var quest_system : = $QuestSystem

var transitioning = false
var combat_arena : CombatArena

func _ready():
	local_map.visible = true
	local_map.spawn_party(party)
	local_map.quest_system = quest_system

func enter_battle(formation: Formation):
	"""
	Plays the combat transition animation and initializes the combat scene
	"""
	if transitioning:
		return
		
	music_player.play_battle_theme()
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	remove_child(local_map)
	combat_arena = combat_arena_scene.instance()
	add_child(combat_arena)
	combat_arena.connect("victory", self, "_on_CombatArena_player_victory")
	combat_arena.connect("gameover", self, "_on_combat_gameover")
	combat_arena.initialize(formation, party.get_active_members())
	yield(transition.fade_from_color(), "completed")
	transitioning = false
	combat_arena.battle_start()
	emit_signal("combat_started")
	
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

func _on_combat_gameover() -> void:
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	game_over_interface.display(GameOverInterface.Reason.PARTY_DEFEATED)
	yield(transition.fade_from_color(), "completed")
	transitioning = false

func _on_GameOverInterface_restart_requested():
	game_over_interface.hide()
	var formation = combat_arena.initial_formation
	combat_arena.queue_free()
	enter_battle(formation)
