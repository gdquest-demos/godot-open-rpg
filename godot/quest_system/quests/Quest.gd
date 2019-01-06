"""
Represents a quest the player can take on
Uses child Objective nodes to track tasks the player has to complete
And Questitem
"""
extends Node
class_name Quest

signal completed(quest)

onready var objectives = $Objectives

export var title : String
export var description : String

export var reward_on_delivery : bool = false
export var reward_experience : int

func _start():
	for objective in get_objectives():
		objective.connect("objective_finished", self, "_on_Objective_finished")

func get_objectives():
	return objectives.get_children()

func get_completed_objectives():
	var completed : Array = []
	for objective in get_objectives():
		if not objective.completed:
			continue
		completed.append(objective)
	return completed

func _on_Objective_finished(objective) -> void:
	if get_completed_objectives().size() == get_objectives().size():
		emit_signal("completed", self)

func notify_slay_objectives() -> void:
	for objective in get_objectives():
		if not objective is QuestSlayObjective:
			continue
		(objective as QuestSlayObjective).connect_signals()

func get_rewards_as_text() -> Array:
	var text : = []
	text.append(" - Experience: %s" % str(reward_experience))
	for item in $ItemRewards.get_children():
		text.append(" - [%s] x (%s)\n" % [item.item.name, str(item.amount)])
	return text
