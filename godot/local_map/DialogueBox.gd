extends Control

onready var dialogue_player : DialoguePlayer = get_node("DialoguePlayer")

onready var name_label : Label = get_node("Panel/Colums/Name")
onready var text_label : Label = get_node("Panel/Colums/Text")

onready var button_next : Button = get_node("Panel/Colums/ButtonNext")
onready var button_finished : Button = get_node("Panel/Colums/ButtonFinished")

func initialize(dialogue):
	button_next.grab_focus()
	button_next.text = "Next"
	dialogue_player.start(dialogue)
	update_content()
	show()

func _on_ButtonNext_pressed() -> void:
	dialogue_player.next()
	update_content()

func _on_DialoguePlayer_finished() -> void:
	button_next.hide()
	button_finished.grab_focus()
	button_finished.show()

func _on_ButtonFinished_pressed() -> void:
	hide()

func update_content() -> void:
	name_label.text = dialogue_player.title
	text_label.text = dialogue_player.text
