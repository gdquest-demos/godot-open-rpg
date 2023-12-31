extends Interaction

@export var item_type: Inventory.ItemTypes
@export var amount: = 1

var _is_open: = false
var _item_received: = false:
	set(value):
		_item_received = value
		if _item_received:
			_popup.hide_and_free()

@onready var _anim: = $AnimationPlayer as AnimationPlayer
@onready var _popup: = $InteractionPopup


# Open or close the chest, depending on whether it is closed or open.
# If this is the first time opening it, apply the items inside to the player's inventory.
func _execute() -> void:
	if _is_open:
		_anim.play("close")
		await _anim.animation_finished
		_is_open = false
	
	else:
		_anim.play("open")
		await _anim.animation_finished
		
		if not _item_received:
			Inventory.restore().add(item_type, amount)
			_item_received = true
		
		_is_open = true
