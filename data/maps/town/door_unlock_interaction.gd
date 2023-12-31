extends Interaction

@onready var door: = get_parent() as Door
@onready var _popup: = $InteractionPopup as InteractionPopup


func _execute() -> void:
	if door.is_locked:
		var inventory: = Inventory.restore()
		if inventory.get_item_count(Inventory.ItemTypes.KEY):
			inventory.remove(Inventory.ItemTypes.KEY, 1)
			door.is_locked = false
			is_active = false
			_popup.is_active = false
		
	door.open()
