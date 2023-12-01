## An exceptionally simple item inventory that tracks which items the player has picked up.
## Normally, inventory design would be more complex. In particular, you would want to separate the
## inventory data structures from the UI implementation, as should be done in a future update to
## the OpenRPG project.
## In this case, we just want to show the player which items have been picked up so that we can demo
## a variety of RPG events.
class_name UIInventory extends HBoxContainer

enum ItemTypes { KEY, COIN, BOMB, RED_WAND, BLUE_WAND, GREEN_WAND }

const ICONS: = {
	ItemTypes.KEY: preload("res://assets/items/key.atlastex"),
	ItemTypes.COIN: preload("res://assets/items/coin.atlastex"),
	ItemTypes.BOMB: preload("res://assets/items/bomb.atlastex"),
	ItemTypes.RED_WAND: preload("res://assets/items/wand_red.atlastex"),
	ItemTypes.BLUE_WAND: preload("res://assets/items/wand_blue.atlastex"),
	ItemTypes.GREEN_WAND: preload("res://assets/items/wand_green.atlastex"),
}

# Keep track of the inventory item packed scene to easily instantiate new items.
var _ITEM_SCENE: = preload("res://src/field/ui/UIInventoryItem.tscn")


## Increment the count of a given item by one, adding it to the inventory if it does not exist.
func add(item_type: ItemTypes, amount: = 1) -> void:
	var item: = _get_item(item_type)
	if not item:
		item = _ITEM_SCENE.instantiate()
		item.ID = item_type
		item.texture = ICONS.get(item_type)
		
		add_child(item)
	
	item.count = item.count + amount


## Decrement the count of a given item by one.
## The item will be removed entirely if there are none remaining. Removing an item that is not
## posessed will do nothing.
func remove(item_type: ItemTypes, amount: = 1) -> void:
	var item: = _get_item(item_type)
	if item:
		item.count = maxi(item.count - amount, 0)


## Returns the number of a certain item type posessed by the player.
func get_item_count(item_type: ItemTypes) -> int:
	var item: = _get_item(item_type)
	if item:
		return item.count
	return 0


func _get_item(item_type: ItemTypes) -> UIInventoryItem:
	for child in get_children():
		if child is UIInventoryItem:
			if child.ID == item_type:
				return child
	return null
