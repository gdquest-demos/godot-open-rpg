## A menu that may have one or more [UIActionMenuPage]s, allowing the player to select actions.
class_name UIActionMenu extends UIListMenu

## Emitted when the player presses an action button.
signal action_selected(action: BattlerAction)

## The menu tracks the [BattlerAction]s available to a single [Battler], depending on Battler state 
## (energy costs, for example).
## The action menu also needs to respond to Battler state, such as a change in energy points or the
## Battler's health.
@export var battler: Battler:
	set(value):
		battler = value
		
		if not is_inside_tree():
			await ready
		
		battler.health_depleted.connect(close)
		
		for action in battler.actions:
			var can_use_action: = battler.stats.energy >= action.energy_cost
			
			var new_entry = _create_entry() as UIActionButton
			new_entry.action = action
			new_entry.disabled = !can_use_action or is_disabled
			
			# Setup callbacks to the action entry's button signals. For these connections, wrap the
			# lambda in parentheses so that we can bind arguments.
			new_entry.pressed.connect(
				# When an action is pressed, the menu should prevent being re-pressed by disabling
				# the entire action menu. Also, forward along which action was pressed.
				(func _on_action_button_pressed(battler_action: BattlerAction) -> void:
					await close()
					action_selected.emit(battler_action)
					).bind(action)
			)
		
			new_entry.focus_entered.connect(
				# Move the cursor to show which entry is currently in focus.
				(func _on_action_button_focus_entered(button: UIActionButton) -> void:
					# Disabled buttons seem to still receive the focus_entered signal, hence the
					# check.
					if not button.disabled:
						_menu_cursor.move_to(button.global_position + 
							Vector2(0.0, button.size.y/2.0))
					).bind(new_entry)
			)
		
		show()
		fade_in()


func _ready() -> void:
	hide()


# Capture any input events that will signal going "back" in the menu hierarchy.
# This includes mouse or touch input outside of a menu or pressing the back button/key.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("select") or event.is_action_released("back"):
		close()


func close() -> void:
	await fade_out()
	queue_free()
	
	CombatEvents.player_battler_selected.emit(null)
