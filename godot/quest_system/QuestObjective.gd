extends Node
class_name QuestObjective

signal objective_finished(objective)

var finished : bool = false

func finish() -> void:
	emit_signal("objective_finished", self)
	finished = true