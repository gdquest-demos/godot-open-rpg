extends Node

signal encounter(enemy_group)

signal dialogue(dialogue)

func _ready():
	connect("dialogue", $MapInterface/Dialogue, "initialize")
