extends Node

signal encounter(enemy_group)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("encounter", get_parent(), "enter_battle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
