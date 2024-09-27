# A button representing a single [BattlerAction].
class_name UIActionButton extends TextureButton

@onready var _icon: = $MarginContainer/Items/Icon
@onready var _name_label: = $MarginContainer/Items/Name


func _ready() -> void:
	pressed.connect(func _on_pressed() -> void:
		release_focus()
	)


## Setup the button's icon and label to match a [BattlerAction], and disable or enable the button
## depending on whether or not the [Battler] can use the action.
func setup(action: BattlerAction, can_be_used: = true) -> void:
	if not is_inside_tree():
		await ready
	
	_icon.texture = action.icon
	_name_label.text = action.label
	
	disabled = not can_be_used
