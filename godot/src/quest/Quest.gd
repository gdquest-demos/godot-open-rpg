# Represents a quest the player can take on
# Uses child Objective nodes to track tasks the player has to complete
# And Questitem
extends Node
class_name Quest

signal started
signal completed
signal delivered

onready var objectives = $Objectives

export var title: String
export var description: String

export var reward_on_delivery: bool = false
export var _reward_experience: int
onready var _reward_items: Node = $ItemRewards


func _start():
	for objective in get_objectives():
		objective.connect("completed", self, "_on_Objective_completed")
	emit_signal("started")


func get_objectives():
	return objectives.get_children()


func get_completed_objectives():
	var completed: Array = []
	for objective in get_objectives():
		if not objective.completed:
			continue
		completed.append(objective)
	return completed


func _on_Objective_completed(objective) -> void:
	if get_completed_objectives().size() == get_objectives().size():
		emit_signal("completed")


func _deliver():
	emit_signal("delivered")


func notify_slay_objectives() -> void:
	for objective in get_objectives():
		if not objective is QuestSlayObjective:
			continue
		(objective as QuestSlayObjective).connect_signals()


func get_rewards() -> Dictionary:
	# Returns the rewards from the quest as a dictionary
	return {'experience': _reward_experience, 'items': _reward_items.get_children()}  # int  # Array of Item


func get_rewards_as_text() -> Array:
	var text := []
	text.append(" - Experience: %s" % str(_reward_experience))
	for item in _reward_items.get_children():
		text.append(" - [%s] x (%s)\n" % [item.item.name, str(item.amount)])
	return text
