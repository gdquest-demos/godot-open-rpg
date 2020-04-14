# Provides a simple API to start and to deliver quests, using the start() and
# deliver() methods respectively.
# Uses 4 QuestContainer nodes to stores all available, active, completed,
# and delivered (finished) quests.
extends Node

onready var available_quests = $Available
onready var active_quests = $Active
onready var completed_quests = $Completed
onready var delivered_quests = $Delivered

var party: Party


func initialize(game, _party: Party) -> void:
	game.connect("combat_started", self, "_on_Game_combat_started")
	party = _party


func find_available(reference: Quest) -> Quest:
	# Returns the Quest corresponding to the reference instance,
	# to track its state or connect to it
	return available_quests.find(reference)


func get_available_quests() -> Array:
	# Returns an Array of all quests under the Available node
	return available_quests.get_quests()


func is_available(reference: Quest) -> bool:
	return available_quests.find(reference) != null


func start(reference: Quest):
	var quest: Quest = available_quests.find(reference)
	quest.connect("completed", self, "_on_Quest_completed", [quest])
	available_quests.remove_child(quest)
	active_quests.add_child(quest)
	quest._start()


func _on_Quest_completed(quest):
	active_quests.remove_child(quest)
	completed_quests.add_child(quest)


func deliver(quest: Quest):
	# Marks the quest as complete, rewards the player,
	# and removes it from completed quests
	quest._deliver()
	# Player rewards
	# TODO: consider removing the tie to the party. Instead maybe let the party node connect to
	# the questsystem and handle rewards by itself?
	var rewards = quest.get_rewards()
	for item in rewards['items']:
		party.inventory.add(item.item, item.amount)
	for party_member in party.get_active_members():
		party_member.experience += rewards['experience']

	assert(quest.get_parent() == completed_quests)
	completed_quests.remove_child(quest)
	delivered_quests.add_child(quest)


func _on_Game_combat_started() -> void:
	for quest in active_quests.get_quests():
		quest.notify_slay_objectives()
