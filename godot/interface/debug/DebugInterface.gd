extends Control

onready var spin_box : SpinBox = $Panel/Column/HBoxContainer/SpinBox

var game_saver : Node = null

func initialize(_game_saver):
	game_saver = _game_saver

func _on_SaveButton_pressed() -> void:
	game_saver.save(spin_box.value)

func _on_LoadButton_pressed() -> void:
	game_saver.load(spin_box.value)
