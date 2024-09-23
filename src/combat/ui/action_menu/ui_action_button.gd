# A button representing a single [BattlerAction].
class_name UIActionButton extends TextureButton

@onready var _icon: = $MarginContainer/Items/Icon
@onready var _name_label: = $MarginContainer/Items/Name


func _ready() -> void:
	pressed.connect(func _on_pressed() -> void:
		release_focus()
	)


func setup(action: BattlerAction, can_be_used: = true) -> void:
	if not is_inside_tree():
		await ready
	
	_icon.texture = action.icon
	_name_label.text = action.label
	
	disabled = not can_be_used
