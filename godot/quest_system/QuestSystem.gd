extends Node
class_name QuestSystem

signal quest_finished(quest)
signal quest_delivered(quest)
signal quest_started(quest)

var quests = []
var party : Party

func initialize(party : Party ) -> void:
	self.party = party

func add_quest(new_quest) -> void:
	add_child(new_quest)
	quests.append(new_quest)
	emit_signal("quest_started", new_quest)
	new_quest.connect("quest_finished", self, "_on_quest_finished")

func _on_quest_finished(quest : Quest) -> void:
	emit_signal("quest_finished", quest)
	if not quest.has_to_be_delivered:
		quest.deliver_quest()
		reward_player(quest)

func _on_Game_combat_started() -> void:
	for quest in quests:
		if quest.finished:
			continue
		(quest as Quest).notify_slay_objectives()

func has_quest(other_quest : Quest) -> bool:
	for quest in quests:
		if quest.title == other_quest.title:
			return true
	return false

func get_finished_quest(other_quest) -> Quest:
	for quest in quests:
		if quest.title == other_quest.title and quest.finished and quest.active:
			return quest
	return null

func reward_player(quest) -> void:
	emit_signal("quest_delivered", quest)
	for item_reward in quest.item_rewards:
		party.inventory.add(item_reward.item, item_reward.amount)

	for party_member in party.get_active_members():
		party_member.battler.stats.experience += quest.exp_reward
		party_member.update_stats(party_member.battler.stats)
