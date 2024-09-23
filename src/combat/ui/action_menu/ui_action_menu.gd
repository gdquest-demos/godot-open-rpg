## A menu that may have one or more [UIActionMenuPage]s, allowing the player to select actions.
class_name UIActionMenu extends Control

## The packed scene used to instantiate action menu pages.
const MENU_PAGE_SCENE: = preload("res://src/combat/ui/action_menu/ui_action_menu_page.tscn")


func _ready() -> void:
	hide()


func open(battler: Battler) -> void:
	var new_page: = MENU_PAGE_SCENE.instantiate()
	add_child(new_page)
	new_page.setup(battler)
	
	new_page.action_selected.connect(
		func _on_menu_page_action_selected(action: BattlerAction) -> void:
			CombatEvents.player_action_selected.emit(action)
			close()
			#action_selected.emit(action)
	)
	
	show()
	new_page.focus_first_button()


func close() -> void:
	hide()
	queue_free()
