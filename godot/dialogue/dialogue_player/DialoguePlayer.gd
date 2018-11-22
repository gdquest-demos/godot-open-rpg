extends Node

class_name DialoguePlayer

var dialogue_keys : Array = []
var dialogue_name : String = ""
var index : int = 0
var dialogue_text : String = ""

signal started
signal finished

func start(dialogue):
	emit_signal("started")
	index = 0
	to_index(dialogue)
	
	dialogue_text = dialogue_keys[index].text
	dialogue_name = dialogue_keys[index].name
	
	if is_finished():
		emit_signal("finished")

func next():
	index += 1
	
	if is_finished():
		emit_signal("finished")
		return
	
	dialogue_text = dialogue_keys[index].text
	dialogue_name = dialogue_keys[index].name

func to_index(dialogue):
	dialogue_keys.clear()
	
	for key in dialogue:
		dialogue_keys.append(dialogue[key])

func is_finished() -> bool:
	return index >= dialogue_keys.size() -1
