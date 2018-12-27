extends Node2D

class_name PartyMember

export var pawn_anim_path : NodePath
onready var battler = $Battler

func _ready():
	assert pawn_anim_path
	battler.stats.reset()

func update_stats(stats : CharacterStats):
	"""
	Update this character's stats to match select changes
	that occurred during combat or through menu actions
	"""
	battler.stats = stats

func ready_for_combat():
	"""
	Returns a copy of the battler to add to the CombatArena
	at the start of a battle
	"""
	return battler.duplicate()

func get_pawn_anim():
	return get_node(pawn_anim_path).duplicate()
