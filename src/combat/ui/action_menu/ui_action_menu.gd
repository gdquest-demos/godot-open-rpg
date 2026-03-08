## A menu lists a [Battler]'s [member Battler._actions], allowing the player to select one.
class_name UIActionMenu extends VBoxContainer

## Emitted when a player has selected an action and the menu has faded to transparent.
signal action_selected(action: BattlerAction)

## Emitted whenever a new action is focused on the menu.
signal action_focused(action: BattlerAction)

## The scene representing the different menu entries. The scene must be some derivation of 
## [BaseButton].
@export var entry_scene: PackedScene

## Determines whether or not the menu is visible and can be affected by player input.
var is_active: = false:
	set(value):
		is_active = value
		visible = is_active
		set_process_unhandled_input(is_active)

@onready var _menu_cursor: = $MenuCursor as UIMenuCursor


func _ready() -> void:
	is_active = false


# Capture any input events that will signal going "back" in the menu hierarchy.
# This includes mouse or touch input outside of a menu or pressing the back button/key.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("select") or event.is_action_released("back"):
		action_selected.emit(null)


## Create the action menu, creating an entry for each [BattlerAction].
func setup(action_list: Array[BattlerAction]) -> void:
	var first_button: UIActionButton = null
	var last_button: UIActionButton = null
	
	if not action_list.is_empty():
		# Create a list of buttons allowing the player to select BattlerActions.
		for action in action_list:
			#var new_entry = _create_entry() as UIActionButton
			var new_entry: = entry_scene.instantiate()
			assert(new_entry is UIActionButton, "Entries to the UIActionMenu must be " +
				"UIActionButtons! A non-UIActionButton entry_scene has been specified.")
			add_child(new_entry)
			
			# We'll populate the menu with duplicates of the BattlerActions in the list.
			# This allows us to set targets without worrying about changing the Battler's copy of
			# the actions.
			new_entry.action = action.duplicate()
			new_entry.action.source = action.source
			new_entry.action.battler_roster = action.battler_roster
			new_entry.disabled = !action.can_execute()
			
			new_entry.focus_entered.connect(_on_entry_focused.bind(new_entry))
			new_entry.mouse_entered.connect(_on_entry_focused.bind(new_entry))
			new_entry.pressed.connect(_on_entry_pressed.bind(new_entry))
			
			last_button = new_entry
		
		# Find the first UIActionButton in the menu. Flag this as the first button.
		for button in get_children():
			if button is UIActionButton:
				first_button = button
				break
		
		# If the menu has more than one entry, link the top and bottom entries (e.g. pressing down while
		# on the bottom entry will cycle the menu selection to the topmost entry).
		if last_button != first_button:
			first_button.focus_neighbor_top = first_button.get_path_to(last_button)
			last_button.focus_neighbor_bottom = last_button.get_path_to(first_button)
	
	# Wait a frame for the menu elements to be setup...
	await get_tree().process_frame
	
	# ...then place the menu cursor - without tweening its position - at the first entry...
	if first_button != null:
		first_button.grab_focus()
		_menu_cursor.position = first_button.global_position + Vector2(0.0, first_button.size.y/2.0)
		_menu_cursor.show()
	
	# ...and finally activate the menu for player input.
	show()
	set_process_unhandled_input(true)


# Moves the [UIMenuCursor] to the focused entry. Derivative menus may want to add additional
# behaviour.
func _on_entry_focused(entry: UIActionButton) -> void:
	_menu_cursor.move_to(entry.global_position + Vector2(0.0, entry.size.y/2.0))
	action_focused.emit(entry.action)


# Override the base method to allow the player to select an action for the specified Battler.
func _on_entry_pressed(entry: BaseButton) -> void:
	var action_entry: = entry as UIActionButton
	var selected_action: BattlerAction = action_entry.action
	
	# First of all, check to make sure that the action has valid targets. If it does
	# not, do not allow selection of the action.
	if selected_action.get_possible_targets().is_empty():
		# Normally, the button gives up focus when selected (to stop cycling menu during animation).
		# However, the action is invalid and so the menu needs to keep focus for the player to
		# select another action.
		entry.grab_focus.call_deferred()
		return
	
	# There are available targets, so the UI can move on to selecting targets.
	action_selected.emit(selected_action)
