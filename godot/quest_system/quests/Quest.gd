extends Node
class_name Quest

signal quest_finished(quest)

export var title : String
export var description : String

var objectives = []
var finished_objectives = []

func _ready() -> void:
	# Connect to signals 
	for objective in get_children():
		objectives.append(objective)
		objective.connect("objective_finished", self, "_on_objective_finished")

func _on_objective_finished(objective) -> void:
	finished_objectives.append(objective)
	if finished_objectives.size() == objectives.size():
		emit_signal("quest_finished", self)

func notify_slay_objectives() -> void:
	for objective in get_children():
		if not objective is QuestSlayObjective:
			continue
		(objective as QuestSlayObjective).connect_signals()
