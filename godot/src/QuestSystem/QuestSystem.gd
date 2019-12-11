extends Node


signal quest_selected(q)

const F_QUESTS : = "res://src/QuestSystem/Data/QuestsTest.json"

var _gui : CanvasLayer = null
var _quest_manager : Node = null


func find_quest(title: String, quests: Dictionary) -> Dictionary:
	var out : = {}
	for key in quests:
		if quests[key].title == title:
			out = quests[key]
	return out


func _ready() -> void:
	_gui = $GUI
	_quest_manager = $QuestsManager
	
	for key in _gui.quest_lists:
		_gui.quest_lists[key].connect("item_selected", self, "_on_QuestsAF_item_selected", [key])
	_quest_manager.connect("quest_added", _gui, "_on_QuestManager_quest_added")
	_quest_manager.setup(F_QUESTS)


func _on_QuestsAF_item_selected(idx: int, which: String) -> void:
	var quests : Dictionary = _quest_manager.quests[which]
	var title : String = _gui.quest_lists[which].get_item_text(idx)
	emit_signal("quest_selected", find_quest(title, quests))