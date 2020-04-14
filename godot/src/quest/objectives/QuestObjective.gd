# Base interface for quest objective nodes. Extend it
# to create specific objectives
extends Node
class_name QuestObjective

signal completed(objective)
signal updated(objective)

var completed: bool = false


func finish() -> void:
	completed = true
	emit_signal("completed", self)


func as_text() -> String:
	return "Objective %s as_text method should be overriden" % get_path()
