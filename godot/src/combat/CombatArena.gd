extends Node2D

class_name CombatArena

const BattlerNode = preload("res://src/combat/battlers/Battler.tscn")

onready var turn_queue: TurnQueue = $TurnQueue
onready var interface = $CombatInterface
onready var rewards = $Rewards

var active: bool = false
var party: Array = []
var initial_formation: Formation

# TODO: Refactor and clean up this script
# sent when the battler is starting to end (before battle_completed)
signal battle_ends
# sent when battle is completed, contains status updates for the party
# so that we may persist the data
signal battle_completed
signal victory
signal game_over


func initialize(formation: Formation, party: Array):
	initial_formation = formation
	ready_field(formation, party)

	# reparent the enemy battlers into the turn queue
	var battlers = turn_queue.get_battlers()
	for battler in battlers:
		battler.initialize()

	interface.initialize(self, turn_queue, battlers)
	rewards.initialize(battlers)
	turn_queue.initialize()


func battle_start():
	yield(play_intro(), "completed")
	active = true
	play_turn()


func play_intro():
	for battler in turn_queue.get_party():
		battler.appear()
	yield(get_tree().create_timer(0.5), "timeout")
	for battler in turn_queue.get_monsters():
		battler.appear()
	yield(get_tree().create_timer(0.5), "timeout")


func ready_field(formation: Formation, party_members: Array):
	# use a formation as a factory for the scene's content
	# @param formation - the combat template of what the player will be fighting
	# @param party_members - list of active party battlers that will go to combat
	for enemy_template in formation.get_children():
		var enemy: Battler = enemy_template.duplicate()
		turn_queue.add_child(enemy)
		enemy.stats.reset()  # ensure the enemy starts with full health and mana

	var party_spawn_positions = $SpawnPositions/Party
	for i in len(party_members):
		# TODO move this into a battler factory and pass already copied info into the scene
		var party_member = party_members[i]
		var spawn_point = party_spawn_positions.get_child(i)
		var battler: Battler = party_member.get_battler_copy()
		battler.position = spawn_point.position
		battler.name = party_member.name
		battler.set_meta("party_member", party_member)
		# stats are copied from the external party member so we may restart combat cleanly,
		# such as allowing players to retry a fight if they get game over
		turn_queue.add_child(battler)
		self.party.append(battler)
		# safely attach the interface to the AI in case player input is needed
		battler.ai.set("interface", interface)


func battle_end():
	emit_signal("battle_ends")
	active = false
	var active_battler = get_active_battler()
	active_battler.selected = false
	var player_won = active_battler.party_member
	if player_won:
		emit_signal("victory")
		yield(rewards.on_battle_completed(), "completed")
		emit_signal("battle_completed")
	else:
		emit_signal("game_over")


func play_turn():
	var battler: Battler = get_active_battler()
	var targets: Array
	var action: CombatAction

	while not battler.is_able_to_play():
		turn_queue.skip_turn()
		battler = get_active_battler()

	battler.selected = true
	var opponents: Array = get_targets()
	if not opponents:
		battle_end()
		return

	action = yield(battler.ai.choose_action(battler, opponents), "completed")
	targets = yield(battler.ai.choose_target(battler, action, opponents), "completed")
	battler.selected = false

	if targets != []:
		yield(turn_queue.play_turn(action, targets), "completed")
	if active:
		play_turn()


func get_active_battler() -> Battler:
	return turn_queue.active_battler


func get_targets() -> Array:
	if get_active_battler().party_member:
		return turn_queue.get_monsters()
	else:
		return turn_queue.get_party()
