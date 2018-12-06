extends Node
class_name MapAction

signal finished()

func interact() -> void:
	print("INTERACTION NOT IMPLEMENTED IN: " + name)
	emit_signal("finished")

