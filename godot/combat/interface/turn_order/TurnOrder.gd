extends Control

onready var last_active_battler : Battler

onready var portraits = $CombatPortraits
var CombatPortrait = preload("res://combat/interface/turn_order/CombatPortrait.tscn")

func rebuild(battlers : Array, active_battler : Battler) -> void:
	"""Creates the turn order interface.
	
	For each battler, both PC and NPC, create its interactive portrait and add 
	it to the portraits list.
	"""
	for portrait in portraits.get_children():
		portrait.queue_free()

	for battler in battlers:
		var new_portrait : CombatPortrait = CombatPortrait.instance()
		portraits.add_child(new_portrait)
		new_portrait.initialize(battler)
		if battler != active_battler:
			new_portrait.reduce()

func next(playing_battler : Battler, deactivate_previous : bool = false) -> void:
	"""Switch to the next battler.
	
	Deactivate the previous portrait and highlight the next one.
	"""
	for portrait in portraits.get_children():
		if portrait.battler == playing_battler:
			portrait.highlight()
		elif portrait.battler == last_active_battler and deactivate_previous:
			portrait.wait()
	last_active_battler = playing_battler

func _on_queue_changed(battlers : Array, active_battler) -> void:
	"""When the turn queue changes, rebuild the turn order interface and highlight the next battler."""
	rebuild(battlers, active_battler)
	next(active_battler)
