## A button representing a single [BattlerAction], shown in the player's [UIActionMenu].
class_name UIActionButton extends TextureButton

## Setup the button's icon and label to match a given [BattlerAction].
var action: BattlerAction:
	set(value):
		action = value
		
		if not is_inside_tree():
			await ready
		
		_icon.texture = action.icon
		_name_label.text = action.label
		
		await get_tree().process_frame
		custom_minimum_size = $MarginContainer.size
		#size = $MarginContainer.size

@onready var _icon: = $MarginContainer/Items/Icon
@onready var _name_label: = $MarginContainer/Items/Name


func _ready() -> void:
	pressed.connect(func _on_pressed() -> void:
		release_focus()
	)
