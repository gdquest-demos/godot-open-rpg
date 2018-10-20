extends Node

class_name CombatAction

signal execute_finished()

export var description : String = "Base combat action"

var actor : Battler
var target : Battler

func execute():
	print("%s missing overwrite of the execute method" % name)
	emit_signal("execute_finished")
