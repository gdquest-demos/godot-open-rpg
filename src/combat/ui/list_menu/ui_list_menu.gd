## A list menu is a template menu that provides common functionality for the combat menus.
##
## A list menu has a number of button entries that may be clicked or navigated to with the arrows,
## buttons, D-pad, etc. A cursor follows the selected menu entry and player input is forwarded via
## a simple set of signals.
class_name UIListMenu extends VBoxContainer

## The scene representing the different menu entries. The scene must be some derivation of 
## [BaseButton].
@export var entry_scene: PackedScene

## Disables or enables clicking on/navigating to the various entries.
## Defaults to true, as most menus will animate into existence before being interactable.
var is_disabled: = true:
	set(value):
		is_disabled = value
		for entry in _entries:
			entry.disabled = is_disabled
		
		focus_first_entry()
		_menu_cursor.visible = !is_disabled

# Track all battler list entries in the following array. 
var _entries: Array[BaseButton] = []

@onready var _anim: = $AnimationPlayer as AnimationPlayer
@onready var _menu_cursor: = $MenuCursor as UIMenuCursor


## Bring the first entry into input focus, moving the cursor to its position.
func focus_first_entry() -> void:
	if not _entries.is_empty():
		_entries[0].grab_focus()
		_menu_cursor.position = _entries[0].global_position + Vector2(0.0, _entries[0].size.y/2.0)


## Fades in the battler list, allowing input and focusing the first button only after the animation
## has finished.
func fade_in() -> void:
	_anim.play("fade_in")
	await _anim.animation_finished
	is_disabled = false
	
	focus_first_entry()


## Fades out the battler list, disabling input to the list beforehand.
func fade_out() -> void:
	is_disabled = true
	_anim.play("fade_out")
	await _anim.animation_finished


# Creates a button entry, based on the specified entry scene. Hooks up automatic callbacks to the
# button's signals that may be modified depending on the specific menu.
# Returns the created entry so that a menu may add additional functionality to the entry.
func _create_entry() -> BaseButton:
	var new_entry: = entry_scene.instantiate()
	assert(new_entry is BaseButton, "Entries to a UIMenuList must be derived from BaseButton!" + 
		" A non-BaseButton entry_scene has been specified.")
	add_child(new_entry)
	
	# We're going to keep these as independent functions rather than inline lambdas, since each menu
	# will probably respond to these events differently. For example, a target menu will want to
	# highlight a specific battler when a new entry is focusd and an action menu will want to
	# forward which action was selected.
	new_entry.focus_entered.connect(_on_entry_focused.bind(new_entry))
	new_entry.mouse_entered.connect(_on_entry_focused.bind(new_entry))
	new_entry.pressed.connect(_on_entry_pressed.bind(new_entry))
	
	_entries.append(new_entry)
	
	if is_disabled:
		new_entry.disabled = true
	return new_entry


func _loop_first_and_last_entries() -> void:
	assert(not _entries.is_empty(), "No action entries for the menu to connect!")
	
	var last_entry_index: = _entries.size()-1
	var first_entry: = _entries[0]
	if last_entry_index > 0:
		var last_entry: = _entries[last_entry_index]
		first_entry.focus_neighbor_top = first_entry.get_path_to(last_entry)
		last_entry.focus_neighbor_bottom = last_entry.get_path_to(first_entry)
	
	elif last_entry_index == 0:
		first_entry.focus_neighbor_top = "."
		first_entry.focus_neighbor_bottom = "."


## Moves the [UIMenuCursor] to the focused entry. Derivative menus may want to add additional
## behaviour.
func _on_entry_focused(entry: BaseButton) -> void:
	_menu_cursor.move_to(entry.global_position + Vector2(0.0, entry.size.y/2.0))


## Hides (and disables) the menu. Derivative menus may want to add additional behaviour.
func _on_entry_pressed(_entry: BaseButton) -> void:
	if not is_disabled:
		fade_out()
