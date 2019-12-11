extends VBoxContainer
class_name Stats


var stats = {}


func setup(new_stats: Dictionary = {}) -> void:
	for child in get_children():
		var key = child.name.to_lower()
		stats[key] = new_stats[key] if key in new_stats else stats[key] if key in stats else 100
		child.value = stats[key]


func _ready() -> void:
	setup()