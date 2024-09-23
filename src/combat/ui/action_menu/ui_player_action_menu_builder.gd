## Is responsible for the creation of the action menu, in response to combat signals.
extends Control

const ACTION_MENU_SCENE: = preload("res://src/combat/ui/action_menu/ui_action_menu.tscn")


func _ready() -> void:
	CombatEvents.player_battler_selected.connect(
		func _on_player_battler_selected(battler: Battler) -> void:
			var action_menu: = ACTION_MENU_SCENE.instantiate()
			add_child(action_menu)
			
			action_menu.open(battler)
	)
