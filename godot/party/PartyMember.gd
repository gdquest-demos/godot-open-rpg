extends Node2D

class_name PartyMember

onready var battler = $Battler

func _ready():
	battler.stats.reset()

func update_stats(stats : CharacterStats):
	"""
	Update this character's stats to match select changes
	that occurred during combat or through menu actions
	"""
	battler.stats = stats

func ready_for_combat():
	var copy = battler.duplicate()
	return copy
