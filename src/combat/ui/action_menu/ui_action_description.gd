@tool
class_name UIActionDescription extends MarginContainer

@export var action: BattlerAction:
	set(value):
		action = value
		
		if not is_inside_tree():
			await ready
		
		if action == null:
			description.text = ""
			hide()
		else:
			description.text = action.description
			show()

@onready var description: = $CenterContainer/MarginContainer/Description as Label


func _ready() -> void:
	if not Engine.is_editor_hint():
		hide()
