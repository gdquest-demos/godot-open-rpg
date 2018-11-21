extends Node

class_name DialoguePlayer

var dialogue_keys : Array = []
var dialogue_name : String = ""
var index : int = 0
var dialogue_text : String = ""

signal dialogue_started
signal dialogue_finished

func start_dialogue(dialogue):
	emit_signal("dialogue_started")
	index = 0
	index_dialogue(dialogue)
	
	dialogue_text = dialogue_keys[index].text
	dialogue_name = dialogue_keys[index].name
	
	if is_finished():
		emit_signal("dialogue_finished")

func next_dialogue():
	index += 1
	
	if is_finished():
		emit_signal("dialogue_finished")
		return
	
	dialogue_text = dialogue_keys[index].text
	dialogue_name = dialogue_keys[index].name

func index_dialogue(dialogue):
	dialogue_keys.clear()
	
	for key in dialogue:
		dialogue_keys.append(dialogue[key])

func is_finished() -> bool:
	return index >= dialogue_keys.size() -1
