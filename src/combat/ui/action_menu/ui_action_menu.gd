## A menu lists a [Battler]'s [member Battler.actions], allowing the player to select one.
class_name UIActionMenu extends UIListMenu

## Emitted when a player has selected an action and the menu has faded to transparent.
signal action_selected(action: BattlerAction)

## Emitted whenever a new action is focused on the menu.
signal action_focused(action: BattlerAction)

# The menu tracks the [BattlerAction]s available to a single [Battler], depending on Battler state 
# (energy costs, for example).
# The action menu also needs to respond to Battler state, such as a change in energy points or the
# Battler's health.
@export var _battler: Battler:
	set(value):
		_battler = value
		
		if not is_inside_tree():
			await ready
		
		# If the battler currently choosing the action dies, close and free the menu.
		_battler.health_depleted.connect(
			func _on_battler_health_depleted():
				await close()
				CombatEvents.player_battler_selected.emit(null)
		)
		
		# If the battler's energy levels changed, re-evaluate which actions are available.
		_battler.stats.energy_changed.connect(
			func _on_battler_energy_changed():
				for entry: UIActionButton in _entries:
					var can_use_action: = _battler.stats.energy >= entry.action.energy_cost
					entry.disabled = !can_use_action or is_disabled
		)

# Refer to the BattlerList to check whether or not an action is valid when it is selected.
# This allows us to prevent the player from selecting an invalid action.
var _battler_list: BattlerList


func _ready() -> void:
	hide()
	set_process_unhandled_input(false)


# Capture any input events that will signal going "back" in the menu hierarchy.
# This includes mouse or touch input outside of a menu or pressing the back button/key.
func _unhandled_input(event: InputEvent) -> void:
	if is_disabled:
		return
	
	if event.is_action_released("select") or event.is_action_released("back"):
		await close()
		CombatEvents.player_battler_selected.emit(null)


## Create the action menu, creating an entry for each [BattlerAction] (valid or otherwise) available
## to the selected [Battler].
## These actions are validated at run-time as they are selected in the menu.
func setup(selected_battler: Battler, battler_list: BattlerList) -> void:
	_battler = selected_battler
	_battler_list = battler_list
	_build_action_menu()
	
	show()
	fade_in()


func fade_in() -> void:
	await super.fade_in()
	set_process_unhandled_input(true)
	

func close() -> void:
	set_process_unhandled_input(false)
	await fade_out()
	queue_free()


# Populate the menu with a list of actions.
func _build_action_menu() -> void:
	for action in _battler.actions:
		var can_use_action: = _battler.stats.energy >= action.energy_cost
		
		var new_entry = _create_entry() as UIActionButton
		new_entry.action = action
		new_entry.disabled = !can_use_action or is_disabled
		new_entry.focus_neighbor_right = "." # Don't allow input to jump to the player battler list.
		
		new_entry.focus_entered.connect(
			(func _on_action_entry_focused(entry_action: BattlerAction) -> void:
				if not is_disabled:
					action_focused.emit(entry_action)).bind(action)
		)
	
	_loop_first_and_last_entries()


# Override the base method to allow the player to select an action for the specified Battler.
func _on_entry_pressed(entry: BaseButton) -> void:
	var action_entry: = entry as UIActionButton
	var action: = action_entry.action
	
	# First of all, check to make sure that the action has valid targets. If it does
	# not, do not allow selection of the action.
	if action.get_possible_targets(_battler, _battler_list).is_empty():
		# Normally, the button gives up focus when selected (to stop cycling menu during animation).
		# However, the action is invalid and so the menu needs to keep focus for the player to
		# select another action.
		entry.grab_focus.call_deferred()
		return
	
	# There are available targets, so the UI can move on to selecting targets.
	await close()
	action_selected.emit(action)
