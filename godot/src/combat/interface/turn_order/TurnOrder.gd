extends Control

onready var last_active_battler: Battler

onready var portraits = $CombatPortraits
var CombatPortrait = preload("res://src/combat/interface/turn_order/CombatPortrait.tscn")


func initialize(combat_arena: CombatArena, turn_queue: TurnQueue):
	combat_arena.connect('battle_ends', self, '_on_battle_ends')
	turn_queue.connect('queue_changed', self, '_on_queue_changed')


func rebuild(battlers: Array, active_battler: Battler) -> void:
	# Creates the turn order interface.

	# For each battler, both PC and NPC, create its interactive portrait and add 
	# it to the portraits list.
	for portrait in portraits.get_children():
		portrait.queue_free()

	for battler in battlers:
		var new_portrait: CombatPortrait = CombatPortrait.instance()
		var play_animation = false if battler == active_battler else true
		portraits.add_child(new_portrait)
		new_portrait.initialize(battler, play_animation)


func next(playing_battler: Battler) -> void:
	# Switch to the next battler.

	# Deactivate the previous portrait and highlight the next one.
	for portrait in portraits.get_children():
		if portrait.battler == playing_battler:
			portrait.highlight()

		elif portrait.battler == last_active_battler:
			portrait.wait()

	last_active_battler = playing_battler


func _on_queue_changed(battlers: Array, active_battler: Battler) -> void:
	# Update the turn order interface according to the battlers state.
	# Only rebuild the interface if the number of battler has changed.
	if battlers.size() != portraits.get_child_count():
		rebuild(battlers, active_battler)

	# Do not update the interface if the turn queue is currently searching for
	# the next battler able to play.
	if active_battler.is_able_to_play():
		next(active_battler)


func _on_battle_ends():
	# When the battle is starting to end, free the turn order interface.
	queue_free()
