extends MapAction
class_name DialogueAction


export var dialogue_box_path : NodePath

onready var dialogue = $Dialogue
onready var dialogue_box = get_node(dialogue_box_path) as DialogueBox

func interact() -> void:
	dialogue_box.initialize(dialogue.load())
	yield(dialogue_box, "dialogue_ended")
	emit_signal("finished")
