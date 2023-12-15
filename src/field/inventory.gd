class_name Inventory extends Resource

enum ItemTypes { KEY, COIN, BOMB, RED_WAND, BLUE_WAND, GREEN_WAND }

signal item_changed(type: ItemTypes)

static var PROFILE_NAME: = "DefaultProfile"

# Keep track of what is in the inventory. Dictionary keys are an ItemType, values are the amount.
@export var _items: = {}


func _init() -> void:
	for item_name in ItemTypes:
		_items[ItemTypes[item_name]] = 0


static func get_profile_path() -> String:
	return "user://profile-%s.tres" % PROFILE_NAME


## Load the [Inventory] from file or create a new resource, if it was missing. Godot caches calls, 
## so this can be used every time needed.
static func restore() -> Inventory:
	if FileAccess.file_exists(Inventory.get_profile_path()):
		var inventory = ResourceLoader.load(Inventory.get_profile_path()) as Inventory
		if inventory:
			print("Found inventory!")
			return inventory
	
	# Either there is no inventory associated with this profile or the file itself could not be
	# loaded. Either way, a new inventory resource must be created.
	var new_inventory: = Inventory.new()
	new_inventory.save()
	print("Created inventory!")
	return new_inventory


## Increment the count of a given item by one, adding it to the inventory if it does not exist.
func add(item_type: ItemTypes, amount: = 1) -> void:
	print(item_type)
	_items[item_type] += amount
	item_changed.emit(item_type)


## Decrement the count of a given item by one.
## The item will be removed entirely if there are none remaining. Removing an item that is not
## posessed will do nothing.
func remove(item_type: ItemTypes, amount: = 1) -> void:
	var old_amount: = _items.get(item_type, 0) as int
	_items[item_type] = maxi(old_amount-amount, 0)
	
	item_changed.emit(item_type)


## Returns the number of a certain item type posessed by the player.
func get_item_count(item_type: ItemTypes) -> int:
	return _items.get(item_type, 0)


func save() -> void:
	ResourceSaver.save(self, Inventory.get_profile_path())
