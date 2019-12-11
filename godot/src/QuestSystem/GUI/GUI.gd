extends CanvasLayer


onready var quest_lists = {
	active = $Container/SlideContainer/Panel/HSplitContainer/VBoxContainer/QuestsActive,
	finished = $Container/SlideContainer/Panel/HSplitContainer/VBoxContainer/QuestsFinished
}

var is_open = false setget set_is_open

var _button_toggle : TextureButton = null
var _button_close : Button = null
var _button_previous : Button = null
var _button_next : Button = null
var _animation_player : AnimationPlayer = null
var _quest_info : VBoxContainer = null

var _count : = 0 setget _set_count


func set_is_open(state: bool) -> void:
	is_open = state


func _ready() -> void:
	_button_toggle = $ButtonToggle
	_button_close = $Container/SlideContainer/Panel/ButtonClose
	_button_previous = $Container/SlideContainer/Panel/HSplitContainer/QuestInfo/HBoxContainer/ButtonPrevious
	_button_next = $Container/SlideContainer/Panel/HSplitContainer/QuestInfo/HBoxContainer/ButtonNext
	_quest_info = $Container/SlideContainer/Panel/HSplitContainer/QuestInfo
	_animation_player = $AnimationPlayer
	
	_button_close.connect("pressed", _animation_player, "play", ["slide_out"])
	_button_toggle.connect("toggled", self, "_on_ButtonToggle_toggled")
	for key in quest_lists:
		_button_previous.connect("pressed", quest_lists[key], "_on_ButtonPN_pressed", [-1, key])
		_button_next.connect("pressed", quest_lists[key], "_on_ButtonPN_pressed", [1, key])
		quest_lists[key].connect("item_selected", self, "_on_QuestsAF_item_selected", [key])
		quest_lists[key].connect("quest_selected", _quest_info, "_on_QuestsAF_quest_selected")
		
	_set_count(0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_open:
		_animation_player.play("slide_out")


func _on_ButtonToggle_toggled(toggled: bool) -> void:
	_animation_player.play("slide_" + ("in" if toggled else "out"))


func _on_QuestManager_quest_added(quest: Dictionary) -> void:
	match quest.status:
		"active", "finished":
			quest_lists[quest.status].add_quest(quest)
			_set_count(_count + 1)
			if _count == 1 and quest.status == "active":
				quest_lists.active.select(0)
				quest_lists.active.emit_signal("item_selected", 0)


func _on_QuestsAF_item_selected(idx: int, which: String) -> void:
	var other : = "active" if which == "finished" else "finished"
	quest_lists[other].unselect_all()


func _set_count(c: int) -> void:
	_count = c
	_quest_info.panel.visible = _count == 0