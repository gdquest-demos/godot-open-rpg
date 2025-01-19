## A menu that may have one or more [UIActionMenuPage]s, allowing the player to select actions.
class_name UIActionMenu extends UIListMenu

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
		
		# If the battler currently choosing the action dies, close and free the menu.
		battler.health_depleted.connect(
			func _on_battler_health_depleted():
				await close()
				CombatEvents.player_battler_selected.emit(null)
				queue_free()
		)
		
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
					#CombatEvents.player_action_selected.emit(battler_action, battler)
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
	set_process_unhandled_input(false)
	
	# When an action is chosen, this menu is merely hidden in case the player decides to go
	# 'back' in the menu hierarchy and choose a new action.
	#CombatEvents.player_targets_selected.connect(
		#func _on_player_targets_selected(targets: Array[Battler]):
			## The player did not choose targets. Unhide the menu so that the player can
			## choose a new action.
			#if targets.is_empty():
				#fade_in()
			#
			## Alternatively, the player has selected targets for the chosen action, in which
			## case the menu may be freed. It is no longer needed.
			#else:
				#queue_free()
	#)


# Capture any input events that will signal going "back" in the menu hierarchy.
# This includes mouse or touch input outside of a menu or pressing the back button/key.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("select") or event.is_action_released("back"):
		await close()
		CombatEvents.player_battler_selected.emit(null)
		queue_free()


func fade_in() -> void:
	await super.fade_in()
	set_process_unhandled_input(true)
	

func close() -> void:
	set_process_unhandled_input(false)
	await fade_out()


# When an action is chosen, this menu is merely hidden in case the player decides to go
# 'back' in the menu hierarchy and choose a new action.
func _on_targets_selected(targets: Array[Battler]) -> void:
	# The player did not choose targets. Unhide the menu so that the player can
	# choose a new action.
	if targets.is_empty():
		fade_in()
	
	# Alternatively, the player has selected targets for the chosen action, in which
	# case the menu may be freed. It is no longer needed.
	else:
		queue_free()
