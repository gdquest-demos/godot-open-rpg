extends ItemList


signal quest_selected(q)

var quests : = []


func _ready():
	connect("item_selected", self, "_on_item_selected")


func _on_item_selected(idx: int) -> void:
	emit_signal("quest_selected", quests[idx])


func _on_ButtonPN_pressed(dir: int, which: String) -> void:
	if which in name.to_lower():
		var count : = get_item_count()
		var idx : = get_selected_items()
		if count > 1 and idx.size() > 0:
			var idx_new : = int(idx[0] + dir)
			idx_new = count - 1 if idx_new < 0 else idx_new % count
			select(idx_new)
			emit_signal("quest_selected", quests[idx_new])


func add_quest(quest: Dictionary) -> void:
	quests.push_back(quest)
	var title : String = "  " + quest.title
	add_item(title)