extends CanvasLayer

onready var lifebar_builder = $BattlersBarsBuilder
onready var select_arrow = $SelectArrow
onready var action_list = $OldSchoolUI/Row/MonstersPanel/ActionSelector/ItemList

var last_selected_action : CombatAction

signal action_selected(action)

func initialize(battlers : Array):
	lifebar_builder.initialize(battlers)
	action_list.hide()

func select_target(selectable_battlers : Array) -> Battler:
	var selected_target : Battler = yield(select_arrow.select_target(selectable_battlers), "completed")
	return selected_target

func update_actions(battler : Battler) -> void:
	action_list.show()
	action_list.clear()
	for index in range(battler.actions.get_child_count()):
		var action = battler.actions.get_children()[index]
		action_list.add_item(action.name)
		if action.skill_to_use != null:
			action_list.set_item_disabled(index, not battler.can_use_skill(action.skill_to_use))
		action_list.set_item_metadata(index, action)
	action_list.select(0)
	action_list.grab_focus()

func _on_ItemList_item_activated(index):
	last_selected_action = action_list.get_item_metadata(index) as CombatAction
	emit_signal("action_selected", last_selected_action)
