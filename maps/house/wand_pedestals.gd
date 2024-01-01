extends Node2D


func _ready() -> void:
	var inventory: = Inventory.restore()
	inventory.item_changed.connect(_on_inventory_item_changed.bind(inventory))


func _on_inventory_item_changed(item_type: Inventory.ItemTypes, inventory: Inventory) -> void:
	match item_type:
		Inventory.ItemTypes.RED_WAND:
			Dialogic.VAR.set_variable("RedWandCount", inventory.get_item_count(item_type))
			print("Now have %d green wands!" % Dialogic.VAR.get_variable("RedWandCount"))
		
		Inventory.ItemTypes.BLUE_WAND:
			Dialogic.VAR.set_variable("BlueWandCount", inventory.get_item_count(item_type))
			print("Now have %d blue wands!" % Dialogic.VAR.get_variable("BlueWandCount"))
			
		Inventory.ItemTypes.GREEN_WAND:
			Dialogic.VAR.set_variable("GreenWandCount", inventory.get_item_count(item_type))
			print("Now have %d green wands!" % Dialogic.VAR.get_variable("GreenWandCount"))
