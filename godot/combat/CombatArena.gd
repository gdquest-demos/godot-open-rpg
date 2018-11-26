extends Node2D

const BattlerNode = preload("res://combat/battlers/Battler.tscn")

onready var turn_queue : TurnQueue = $TurnQueue
onready var interface = $CombatInterface
onready var rewards = $Rewards

var active : bool = false
var party : Array = []

signal victory
signal gameover
# send when battle is completed, contains status updates for the party
# so that we may persist the data
signal completed(party) 

func initialize(formation : Formation, party : Array):
	ready_field(formation, party)
		
	# reparent the enemy battlers into the turn queue
	var battlers = turn_queue.get_battlers()
	interface.initialize(battlers)
	rewards.initialize(battlers)
	turn_queue.initialize()
	
func battle_start():
	yield(play_intro(), "completed")
	active = true
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

func ready_field(formation : Formation, party_members : Array):
	"""
	use a formation as a factory for the scene's content
	@param formation - the combat template of what the player will be fighting
	@param party_members - list of active party battlers that will go to combat
	"""
	var spawn_positions = $SpawnPositions/Monsters
	for enemy in formation.get_children():
	 	# spawn a platform where the enemy is supposed to stand
		var platform = formation.platform_template.instance()
		platform.position = enemy.position
		spawn_positions.add_child(platform)
		var combatant = BattlerNode.instance()
		combatant.template = enemy.combat_template
		combatant.position = enemy.position
		combatant.display_name = enemy.display_name
		turn_queue.add_child(combatant)
		
	var party_spawn_positions = $SpawnPositions/Party
	for i in len(party_members):
		# TODO move this into a battler factory and pass already copied info into the scene
		var party_member = party_members[i]
		var template = party_member.combat_template
		var platform = formation.platform_template.instance()
		var spawn_point = party_spawn_positions.get_child(i)
		platform.position = spawn_point.position
		var combatant = BattlerNode.instance() as Battler
		combatant.party_member = true
		combatant.position = spawn_point.position
		combatant.template = template
		combatant.name = party_member.name
		# stats are copied from the external party member so we may restart combat cleanly,
		# such as allowing players to retry a fight if they get game over
		var stats = party_member.persistent_status.copy()
		combatant.stats = stats
		spawn_point.replace_by(platform)
		turn_queue.add_child(combatant)
		self.party.append(combatant)
		
	formation.queue_free()

func battle_end():
	active = false
	var player_lost = get_active_battler().party_member
	if player_lost:
		yield(rewards.on_battle_completed(), "completed")
		emit_signal("completed", self.party)
	else:
		emit_signal("completed", self.party)
		emit_signal("gameover")

func play_turn():
	var battler : Battler = get_active_battler()
	if battler.stats.health > 0:
		battler.selected = true
		
		var targets : Array = get_targets()
		if not targets:
			battle_end()
			return
		var target : Battler
		var action : CombatAction
		if battler.party_member:
			interface.update_actions(battler)
			action = yield(interface, "action_selected")
		else:
			# Temp random target selection for the monsters
			action = get_active_battler().actions.get_child(0)
			action.target = battler.choose_target(targets)
		yield(turn_queue.play_turn(action), "completed")
		battler.selected = false
	else:
		turn_queue.skip_turn()
	
	if active:
		play_turn()

func get_active_battler() -> Battler:
	return turn_queue.active_battler

func get_targets() -> Array:
	if get_active_battler().party_member:
		return turn_queue.get_monsters()
	else:
		return turn_queue.get_party()
