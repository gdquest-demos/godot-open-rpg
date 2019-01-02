extends Control
class_name QuestJournal

onready var tree = $Column/Tree as Tree

export var quest_active_icon : Texture
export var quest_inactive_icon : Texture
export var quest_finished_icon : Texture
export var quest_objective_finished : Texture
export var quest_objective_unfinished : Texture

var tree_root
var active = false

func _ready() -> void:
	tree.set_hide_root(true)
	tree_root = tree.create_item()
	
func get_quest_icon(quest) -> Texture:
	if not quest.active:
		return quest_inactive_icon
	if quest.finished:
		return quest_finished_icon
	return quest_active_icon

func add_quest(quest) -> void:
	var item = tree.create_item(tree_root)
	item.set_icon(0, get_quest_icon(quest))
	item.set_text(0, quest.title)
	item.set_selectable(0, false)
	item.set_metadata(0, quest)
	item.collapsed = true
	for objective in quest.objectives:
		var objective_item = tree.create_item(item)
		objective_item.set_text(0, objective.title)
		objective_item.set_selectable(0, false)
		objective_item.set_icon(0, quest_objective_finished if objective.finished else quest_objective_unfinished)

func mark_quest_as_finished(quest) -> void:
	var quest_item = tree_root.get_children()
	while true:
		if quest_item.get_metadata(0) == quest:
			quest_item.set_icon(0, quest_finished_icon)
			break
		quest_item = quest_item.get_next()

func mark_quest_as_delivered(quest) -> void:
	var quest_item = tree_root.get_children()
	while true:
		if quest_item.get_metadata(0) == quest:
			quest_item.set_icon(0, quest_inactive_icon)
			break
		quest_item = quest_item.get_next()
