@tool
# An interaction that opens and closes an animated chest and adds an item to the player's inventory.
# The item is only added the first time the player opens the chest.
extends Interaction

@export var anim: AnimationPlayer
@export var popup: InteractionPopup

var item_type: Inventory.ItemTypes
var amount: = 1

var _is_open: = false
var _item_received: = false:
	set(value):
		_item_received = value
		if _item_received:
			popup.hide_and_free()


# Open or close the chest, depending on whether it is closed or open.
# If this is the first time opening it, apply the items inside to the player's inventory.
func _execute() -> void:
	if _is_open:
		anim.play("close")
		await anim.animation_finished
		_is_open = false
	
	else:
		anim.play("open")
		await anim.animation_finished
		
		if not _item_received:
			Inventory.restore().add(item_type, amount)
			_item_received = true
		
		_is_open = true
