extends Control

onready var dialogue_player : DialoguePlayer = get_node("DialoguePlayer")
onready var name_label : Label = get_node("Panel/Colums/Name")
onready var text_label : Label = get_node("Panel/Colums/Text")
onready var next_button : Button = get_node("Panel/Colums/Next")

func _ready():
	next_button.connect("button_down", self, "_on_next_button_down")
	dialogue_player.connect("finished", self, "_on_dialogue_player_finished")
	
func initialize(dialogue):
	next_button.grab_focus()
	next_button.text = "Next"
	
	dialogue_player.start_dialogue(dialogue)
	
	update_content()
	show()

func _on_dialogue_player_finished():
	next_button.text = "Finished"
	
	yield(next_button, "button_down")
	
	hide()

func _on_next_button_down():
	dialogue_player.next_dialogue()
	update_content()
	
func update_content() -> void:
	name_label.text = dialogue_player.dialogue_name
	text_label.text = dialogue_player.dialogue_text
