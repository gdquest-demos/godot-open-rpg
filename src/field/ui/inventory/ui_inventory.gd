## An exceptionally simple item inventory that tracks which items the player has picked up.
## Normally, inventory design would be more complex. In particular, you would want to separate the
## inventory data structures from the UI implementation, as should be done in a future update to
## the OpenRPG project.
## In this case, we just want to show the player which items have been picked up so that we can demo
## a variety of RPG events.
class_name UIInventory extends HBoxContainer

# Keep track of the inventory item packed scene to easily instantiate new items.
var _ITEM_SCENE: = preload("res://src/field/ui/inventory/ui_inventory_item.tscn")


func _ready() -> void:
	var inventory: = Inventory.restore()
	
	for item_name in Inventory.ItemTypes:
		_update_item(Inventory.ItemTypes[item_name], inventory)
	inventory.item_changed.connect(_on_inventory_item_changed.bind(inventory))


func get_ui_item(item_id: Inventory.ItemTypes) -> UIInventoryItem:
	for child in get_children():
		var item: = child as UIInventoryItem
		if item and item.ID == item_id:
			return item
	return null


func _update_item(item_id: Inventory.ItemTypes, inventory: Inventory) -> void:
	var amount: = inventory.get_item_count(item_id)
	var item: = get_ui_item(item_id)
	
	if amount > 0:
		if not item:
			item = _ITEM_SCENE.instantiate() as UIInventoryItem
			item.ID = item_id
			item.texture = Inventory.get_item_icon(item_id)
			add_child(item)
		
		item.count = amount
	
	else:
		if item:
			item.queue_free()


func _on_inventory_item_changed(item_type: Inventory.ItemTypes, inventory: Inventory) -> void:
	_update_item(item_type, inventory)
