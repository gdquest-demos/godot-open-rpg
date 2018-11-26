extends Reference

class_name Inventory

export(int) var MAX_COINS = 999
var coins : int = 0
var content = {}

signal item_count_changed(item, amount)
signal coins_count_changed(amount)

func add(item: Item, amount: int = 1) -> void:
	if not content.has(item):
		content[item] = 1 if item.is_unique else amount
	else:
		content[item] += amount

func remove(item: Item, amount: int = 1):
	assert amount <= content[item]
	content[item] -= amount
	if content[item] == 0:
		content.erase(item)
		emit_signal("item_count", item, 0)
	else:
		emit_signal("item_count", item, content[item])
	
func add_coins(amount: int) -> void:
	coins = min(coins + amount, MAX_COINS)
	emit_signal("coins_changed", coins)

func remove_coins(amount: int) -> void:
	coins = max(0, coins - amount)
	emit_signal("coins_changed", coins)

func get_consumables() -> Array:
	var consumable: Array
	for item in content.keys():
		if item is ConsumableItem:
			consumable.append(item)
	return consumable

func get_equipment() -> Array:
	var equipment: Array
	for item in content.keys():
		if item is Equipment:
			equipment.append(item)
	return equipment

func get_unique_items() -> Array:
	var unique: Array
	for item in content.keys():
		if item is ConsumableItem:
			unique.append(item)
	return unique
