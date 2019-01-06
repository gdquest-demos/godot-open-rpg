"""

"""
extends Node

signal delivered(quest)

onready var available_quests = $Available
onready var active_quests = $Active
onready var completed_quests = $Completed
onready var delivered_quests = $Delivered

var party : Party

func initialize(_party : Party ) -> void:
	party = _party

func is_available(_quest : Quest) -> bool:
	return available_quests.find(_quest) != null

func start(_quest : Quest):
	var quest : Quest = available_quests.find(_quest)
	quest.connect("completed", self, "_on_Quest_completed")
	available_quests.remove_child(quest)
	active_quests.add_child(quest)
	quest._start()

func _on_Quest_completed(quest):
	active_quests.remove_child(quest)
	completed_quests.add_child(quest)

func deliver(_quest : Quest):
	"""
	Marks the quest as complete, rewards the player, 
	and removes it from available quests
	"""
	var quest : Quest = completed_quests.find(_quest)
	completed_quests.remove_child(quest)
	delivered_quests.add_child(quest)
	emit_signal("delivered", quest)

	# Player rewards
	# TODO: consider removing the tie to the party. Instead maybe let the party node connect to
	# the questsystem and handle rewards by itself?
	for item in quest.reward_items:
		party.inventory.add(item.item, item.amount)
	# TODO: Simplify the stats API on PartyMember. party_member.experience += value
	# should level up the character and update the stats automatically
	# so that all the code stays in PartyMember.gd
	for party_member in party.get_active_members():
		party_member.battler.stats.experience += quest.reward_experience
		party_member.update_stats(party_member.battler.stats)

func _on_Game_combat_started() -> void:
	for quest in active_quests.get_quests():
		quest.notify_slay_objectives()
