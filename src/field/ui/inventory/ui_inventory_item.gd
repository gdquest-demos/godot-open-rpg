## An inventory item, tracking both it's UI representation and underlying data.
## Will be replaced in future iterations of the OpenRPG project.
## Please see UIInventory for additional information.
class_name UIInventoryItem extends TextureRect

var ID: = Inventory.ItemTypes.KEY

var count: = 0:
	set = set_count

@onready var _count_label: = $Count as Label


func set_count(value: int) -> void:
	count = max(value, 0)
	if count == 0:
		queue_free()
	
	elif count > 1:
		_count_label.show()
		_count_label.text = str(count)
	
	else:
		_count_label.hide()
