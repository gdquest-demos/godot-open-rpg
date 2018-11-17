extends Node2D

onready var turn_queue : TurnQueue = $TurnQueue
onready var interface = $CombatInterface
onready var rewards = $Rewards

var active : bool = false

signal victory
signal gameover
func initialize(formation : Formation, party : Party):
	ready_field(formation, party)
		
	# reparent the enemy battlers into the turn queue
	var battlers = turn_queue.get_battlers()
	interface.initialize(battlers)
	rewards.initialize(battlers)
	turn_queue.initialize()
	
func battle_start():
	active = true
	yield(play_intro(), "completed")
	play_turn()

func play_intro():
	# Play the appear animation on all battlers in cascade
	for battler in turn_queue.get_party():
		battler.appear()
		yield(get_tree().create_timer(0.15), "timeout")
	yield(get_tree().create_timer(0.8), "timeout")
	for battler in turn_queue.get_monsters():
		battler.appear()
		yield(get_tree().create_timer(0.15), "timeout")
	yield(get_tree().create_timer(0.8), "timeout")

func ready_field(formation : Formation, party : Party):
	"""
	use a formation as a factory for the scene's content
	"""
	var spawn_positions = $SpawnPositions/Monsters
	for enemy in formation.get_children():
	 	# spawn a platform where the enemy is supposed to stand
		var platform = formation.platform_template.instance()
		platform.position = enemy.position
		spawn_positions.add_child(platform)
		var combatant = enemy.duplicate()
		turn_queue.add_child(combatant)
		
	var party_spawn_positions = $SpawnPositions/Party
	var party_members = party.get_members()
	for i in len(party_members):
		var party_member = party_members[i].duplicate()
		var platform = formation.platform_template.instance()
		var spawn_point = party_spawn_positions.get_child(i)
		platform.position = spawn_point.position
		party_member.position = spawn_point.position
		spawn_point.replace_by(platform)
		turn_queue.add_child(party_member)
		
	formation.queue_free()

func battle_end():
	active = false
	var player_lost = get_active_battler().party_member
	if player_lost:
		emit_signal("victory")
	else:
		emit_signal("gameover")

func play_turn():
	var battler : Battler = get_active_battler()
	battler.selected = true
	
	var targets : Array = get_targets()
	if not targets:
		battle_end()
		return
	var target : Battler
	var action : CombatAction
	if battler.party_member:
		interface.update_actions(battler)
		target = yield(interface.select_target(targets), "completed")
#		action = get_active_battler().actions.get_child(0)
		action = interface.selected_action
	else:
		# Temp random target selection for the monsters
		target = battler.choose_target(targets)
		action = get_active_battler().actions.get_child(0)

	yield(turn_queue.play_turn(target, action), "completed")
	
	battler.selected = false
	if active:
		play_turn()

func get_active_battler() -> Battler:
	return turn_queue.active_battler

func get_targets() -> Array:
	if get_active_battler().party_member:
		return turn_queue.get_monsters()
	else:
		return turn_queue.get_party()
