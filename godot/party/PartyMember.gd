"""
Represents a playable character to add in the player's party
Holds the data and nodes for the character's battler, pawn on the map,
and the character's stats to save the game
"""
extends Node2D

class_name PartyMember

export var pawn_anim_path : NodePath
export var growth : Resource

onready var battler = $Battler

signal level_changed(new_value, old_value)

func _ready():
	assert pawn_anim_path
	assert growth
	refresh_stats()
	battler.stats.reset()

func update_stats(stats : CharacterStats):
	"""
	Update this character's stats to match select changes
	that occurred during combat or through menu actions
	"""
	var before_level = growth.get_level(battler.stats.experience)
	var after_level = growth.get_level(stats.experience)	
	battler.stats = stats
	
	if before_level != after_level:
		refresh_stats()
		emit_signal("level_changed", after_level, before_level)

func ready_for_combat():
	"""
	Returns a copy of the battler to add to the CombatArena
	at the start of a battle
	"""
	return battler.duplicate()

func get_pawn_anim():
	"""
	Returns a copy of the PawnAnim that represents this character,
	e.g. to add it as a child of the currently loaded game map
	"""
	return get_node(pawn_anim_path).duplicate()

func refresh_stats():
	var stats = growth.create_stats(battler.stats.experience)
	# TODO apply equipment stats
	stats.reset()
	battler.stats = stats
	