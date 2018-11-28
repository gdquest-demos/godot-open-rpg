extends Node

signal enemies_encountered(formation)

signal dialogue(dialogue)

func _ready():
	connect("dialogue", $MapInterface/Dialogue, "initialize")

func _on_Grid_enemies_encountered(formation) -> void:
	emit_signal("enemies_encountered", formation)
