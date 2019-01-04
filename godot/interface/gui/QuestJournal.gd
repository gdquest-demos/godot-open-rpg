extends Control
class_name QuestJournal

signal journal_updated()

onready var tree : = $Column/Tree

export var quest_active_icon : Texture
export var quest_inactive_icon : Texture
export var quest_finished_icon : Texture
export var quest_objective_finished : Texture
export var quest_objective_unfinished : Texture

var tree_root : TreeItem
var active : = false

func initialize(quest_system : QuestSystem) -> void:
	quest_system.connect("quest_started", self, "_on_quest_started")
	quest_system.connect("quest_finished", self, "_on_quest_finished")
	quest_system.connect("quest_delivered", self, "_on_quest_delivered")

func _ready() -> void:
	tree.set_hide_root(true)
	tree_root = tree.create_item()
	
func _get_quest_icon(quest : Quest) -> Texture:
	if not quest.active:
		return quest_inactive_icon
	if quest.finished:
		return quest_finished_icon
	return quest_active_icon

func _on_quest_started(quest : Quest) -> void:
	emit_signal("journal_updated")
	var quest_root = _add_tree_item(tree_root, quest.title, _get_quest_icon(quest), quest)
	_add_tree_item(quest_root, quest.description)
	for reward_text in quest.get_rewards_as_text():
		_add_tree_item(quest_root, reward_text)
	for objective in quest.objectives:
		objective.connect("objective_updated", self, "_on_objective_updated")
		objective.connect("objective_finished", self, "_on_objective_finished")
		_add_tree_item(quest_root, objective.as_text(),\
			quest_objective_finished if objective.finished else quest_objective_unfinished, objective)

func _add_tree_item(root : TreeItem, text : String, icon : Texture = null, metadata = null, selectable : bool = false, collapsed : bool = true) -> TreeItem:
	var item = tree.create_item(root)
	item.set_icon(0, icon)
	item.set_text(0, text)
	item.set_selectable(0, selectable)
	item.collapsed = collapsed
	if metadata != null:
		item.set_metadata(0, metadata)
	return item

func _on_objective_updated(objective : QuestObjective) -> void:
	var objective_item = _find_quest_objective_tree_item(objective)
	if objective_item == null:
		return
	objective_item.set_text(0, objective.as_text())

func _on_objective_finished(objective : QuestObjective) -> void:
	var objective_item = _find_quest_objective_tree_item(objective)
	if objective_item == null:
		return
	objective_item.set_icon(0, quest_objective_finished)
	objective_item.set_text(0, objective.as_text())

func _on_quest_finished(quest : Quest) -> void:
	emit_signal("journal_updated")
	var quest_item = _find_quest_tree_item(quest)
	if quest_item == null:
		return
	quest_item.set_icon(0, quest_finished_icon)

func _on_quest_delivered(quest : Quest) -> void:
	emit_signal("journal_updated")
	var quest_item = _find_quest_tree_item(quest)
	if quest_item == null:
		return
	quest_item.set_icon(0, quest_inactive_icon)

func _find_quest_tree_item(quest : Quest) -> TreeItem:
	var quest_item = tree_root.get_children()
	while quest_item != null:
		if quest_item.get_metadata(0) == quest:
			return quest_item
		quest_item = quest_item.get_next()
	return null

func _find_quest_objective_tree_item(objective : QuestObjective) -> TreeItem:
	var quest_item = tree_root.get_children()
	while quest_item != null:
		var objective_item = quest_item.get_children()
		while objective_item != null:
			if objective_item.get_metadata(0) != null and objective_item.get_metadata(0) == objective:
				return objective_item
			objective_item = objective_item.get_next()
		quest_item = quest_item.get_next()
	return null
