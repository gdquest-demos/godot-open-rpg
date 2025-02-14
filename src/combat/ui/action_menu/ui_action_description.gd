## A text bar that displays the [member BattlerAction.description] of a [BattlerAction].
##
## This bar is shown to give the player information about actions as they select one from the
## [UIActionMenu].
@tool
class_name UIActionDescription extends MarginContainer

@export var description: = "":
	set(value):
		description = value
		
		if not is_inside_tree():
			await ready
			
		_description_label.text = description
		if description.is_empty():
			hide()
		else:
			show()

@onready var _description_label: = $CenterContainer/MarginContainer/Description as Label


func _ready() -> void:
	if not Engine.is_editor_hint():
		hide()
