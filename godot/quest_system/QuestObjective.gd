extends Node
class_name QuestObjective

signal objective_finished(objective)
signal objective_updated(objective)

var finished : bool = false

func finish() -> void:
	finished = true
	emit_signal("objective_finished", self)

func as_text() -> String:
	return "OBJECTIVE TEXT NOT SET"