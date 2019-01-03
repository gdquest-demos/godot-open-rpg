extends Node
class_name Quest

signal quest_finished(quest)

export var title : String
export var description : String
export var exp_reward : int
export var has_to_be_delivered : bool = false

var item_rewards = []
var objectives = []
var finished_objectives = []

var active : bool = false
var finished : bool = false

func _ready() -> void:
	active = true
	item_rewards = $ItemRewards.get_children()
	for objective in $Objectives.get_children():
		objectives.append(objective)
		objective.connect("objective_finished", self, "_on_objective_finished")

func _on_objective_finished(objective) -> void:
	finished_objectives.append(objective)
	if finished_objectives.size() == objectives.size():
		emit_signal("quest_finished", self)
		finished = true

func deliver_quest() -> void:
	active = false

func notify_slay_objectives() -> void:
	for objective in objectives:
		if not objective is QuestSlayObjective:
			continue
		(objective as QuestSlayObjective).connect_signals()

func get_rewards_as_text() -> Array:
	var rewards : = []
	rewards.append(" - Experience: %s" % str(exp_reward))
	for item_reward in item_rewards:
		rewards.append(" - [%s] x (%s)\n" % [item_reward.item.name, str(item_reward.amount)])
	return rewards
