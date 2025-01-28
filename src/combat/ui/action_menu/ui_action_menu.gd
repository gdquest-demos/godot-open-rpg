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
		)
		
		# If the battler's energy levels changed, re-evaluate which actions are available.
		battler.stats.energy_changed.connect(
			func _on_battler_energy_changed():
				for entry: UIActionButton in _entries:
					var can_use_action: = battler.stats.energy >= entry.action.energy_cost
					entry.disabled = !can_use_action or is_disabled
		)
		
		_build_action_menu()
		
		show()
		fade_in()


func _ready() -> void:
	hide()
	set_process_unhandled_input(false)


# Capture any input events that will signal going "back" in the menu hierarchy.
# This includes mouse or touch input outside of a menu or pressing the back button/key.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("select") or event.is_action_released("back"):
		await close()
		CombatEvents.player_battler_selected.emit(null)


func fade_in() -> void:
	await super.fade_in()
	set_process_unhandled_input(true)
	

func close() -> void:
	set_process_unhandled_input(false)
	await fade_out()
	queue_free()


# Populate the menu with a list of actions.
func _build_action_menu() -> void:
	assert(battler, "Must assign a Battler before building the action menu!")
	
	for action in battler.actions:
		var can_use_action: = battler.stats.energy >= action.energy_cost
		
		var new_entry = _create_entry() as UIActionButton
		new_entry.action = action
		new_entry.disabled = !can_use_action or is_disabled
		new_entry.focus_neighbor_right = "." # Don't allow input to jump to the player battler list.
		
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
				_menu_cursor.move_to(button.global_position + 
					Vector2(0.0, button.size.y/2.0))
				).bind(new_entry)
		)
	
	# Link the focus order of the entries to loop through the menu easily.
	var last_entry_index: = _entries.size()-1
	if last_entry_index > 0:
		var first_entry: = _entries[0]
		var last_entry: = _entries[last_entry_index]
		first_entry.focus_neighbor_top = first_entry.get_path_to(last_entry)
		last_entry.focus_neighbor_bottom = last_entry.get_path_to(first_entry)
