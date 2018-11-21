extends Node

signal encounter(enemy_group)

signal dialogue(dialogue)

func _ready():
	connect("dialogue", $MapInterface/Dialogue, "_on_LocalMap_dialogue_started")