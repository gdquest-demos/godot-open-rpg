extends Reference

class_name Inventory

enum Operator {
	ADD,
	SET
}

# Currency acquired for use in shopping
var balance = 500
# Counters for items contained in the inventory
var buckets = {}

signal item_count(item, amount)
signal balance_changed(new_amount, old_amount)

func has_item(item: Item):
	return buckets.has(item)
	
func adjust_held(item: Item, amount: int = 1, operator = Operator.ADD) -> bool:
	match operator:
		ADD:
			# safely add the item into the inventory
			if buckets.has(item):
				# prevent taking out more than the player has
				if buckets[item] + amount < 0:
					return false
				# ignore picking up more than one of a key item
				if item.is_key and buckets[item] + amount > 1:
					return false
				buckets[item] += amount
			else:
				buckets[item] = amount
		SET:
			if amount < 0:
				return false
			buckets[item] = amount
	
	if buckets[item] <= 0:
		buckets.erase(item)
		emit_signal("item_count", item, 0)
	else:
		emit_signal("item_count", item, buckets[item])
	return true
	
func adjust_balance(amount: int, operator = Operator.ADD) -> bool:
	var old = balance
	
	# prevent overcharging a user when shopping
	match operator:
		ADD:
			if balance + amount < 0:
				return false
			balance += amount
		SET:
			if amount < 0:
				return false
			balance = amount
	
	emit_signal("balance_changed", balance, old)
	return true

func get_consumables() -> Array:
	var usable = []
	for item in buckets.keys():
		if item is ConsumableItem:
			usable.append(item)
	return usable

func get_equipment() -> Array:
	var equipment = []
	for item in buckets.keys():
		if item is Equipment:
			equipment.append(item)
	return equipment

func get_key_items() -> Array:
	var keys = []
	for item in buckets.keys():
		if item is ConsumableItem:
			keys.append(item)
	return keys
