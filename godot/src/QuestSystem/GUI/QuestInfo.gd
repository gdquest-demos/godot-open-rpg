extends Container


#warning-ignore:unused_class_variable
onready var panel : Panel = $Panel

const ObjectiveItem : = preload("res://src/QuestSystem/GUI/ObjectiveItem.tscn")
const RewardItem : = preload("res://src/QuestSystem/GUI/RewardItem.tscn")

var _title : RichTextLabel = null
var _description : RichTextLabel = null
var _objectives : VBoxContainer = null
var _rewards : VBoxContainer = null


func _ready() -> void:
	_title = $HBoxContainer/MarginContainer/VBoxContainer/Title
	_description = $HBoxContainer/MarginContainer/VBoxContainer/ContainerDescription/Content
	_objectives = $HBoxContainer/MarginContainer/VBoxContainer/ContainerObjectives/Content/List
	_rewards = $HBoxContainer/MarginContainer/VBoxContainer/ContainerRewards/Content/List


func _on_QuestsAF_quest_selected(quest: Dictionary) -> void:
	_populate_title(quest.title)
	_populate_description(quest.description)
	_populate_objectives(quest.objectives)
	_populate_rewards(quest.rewards)

func _populate_title(t: String) -> void:
	_title.bbcode_text = "[b]" + t + "[/b]"


func _populate_description(d: String) -> void:
	_description.bbcode_text = d


func _populate_objectives(os: Array) -> void:
	for o in _objectives.get_children():
		o.queue_free()

	for o in os:
		var objective : = ObjectiveItem.instance()
		_objectives.add_child(objective)
		objective.setup(o)


func _populate_rewards(rs: Array) -> void:
	for r in _rewards.get_children():
		r.queue_free()

	for r in rs:
		var reward : = RewardItem.instance()
		_rewards.add_child(reward)
		reward.setup(r)