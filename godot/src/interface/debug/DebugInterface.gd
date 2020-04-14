extends Control

onready var spin_box: SpinBox = $Column/HBoxContainer/SpinBox
onready var game_saver: Node = $GameSaver


func _on_SaveButton_pressed() -> void:
	game_saver.save(spin_box.value)


func _on_LoadButton_pressed() -> void:
	game_saver.load(spin_box.value)
