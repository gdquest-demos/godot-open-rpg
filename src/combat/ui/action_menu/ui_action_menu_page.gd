## A page in a [UIActionMenu], containing a list of actions that the player may select.
##
## A menu page may be, for example, a list of special attacks or a list of items, or the top-level
## list of actions (e.g. Attack, Defend, Items, etc.) that may lead to other menu pages.
class_name UIActionMenuPage extends VBoxContainer

## Emitted when the player presses an action button.
signal action_selected(action: BattlerAction)

## The packed scene used to instantiate action menu buttons.
const ACTION_BUTTON_SCENE: = preload("res://src/combat/ui/action_menu/ui_action_button.tscn")

## Disables or enables all action button children.
var is_disabled: = false:
	set(value):
		is_disabled = value
		for button in _buttons:
			button.disabled = is_disabled

# Track which children are buttons, since one is a cursor.
var _buttons: Array[UIActionButton] = []

@onready var _cursor: = $ActionMenuCursor as UIActionMenuCursor


## Setup the menu page for use, populating it with a list of actions.
func setup(battler: Battler) -> void:
	for action in battler.actions:
		var can_use_action: = battler.stats.energy >= action.energy_cost
		
		var action_button: = ACTION_BUTTON_SCENE.instantiate()
		add_child(action_button)
		action_button.setup(action, can_use_action)
		
		action_button.pressed.connect(
			# For the next two connections, wrap the lambda in parentheses so that we can bind an
			# argument or two.
			(func _on_action_button_pressed(battler_action: BattlerAction) -> void:
				is_disabled = true
				action_selected.emit(battler_action)
				
				).bind(action)
		)
		
		action_button.focus_entered.connect(
			(func _on_action_button_focus_entered(button: TextureButton, 
					_battler_display_name: String, _energy_cost: int) -> void:
				_cursor.move_to(button.global_position + Vector2(0.0, button.size.y/2.0))
				
				).bind(action_button, "BattlerName", action.energy_cost)
		)
		
		_buttons.append(action_button)
	
	focus_first_button()


## Have the first action button grab focus, if it exists.
func focus_first_button() -> void:
	if not _buttons.is_empty():
		_buttons[0].grab_focus()
		_cursor.position = _buttons[0].global_position + Vector2(0.0, _buttons[0].size.y/2.0)


#func _on_action_button_pressed(action: BattlerAction) -> void:
	#is_disabled = true
	#action_selected.emit(action)


#func _on_action_button_focus_entered(button: TextureButton, _battler_display_name: String, 
		#_energy_cost: int) -> void:
	#_cursor.move_to(button.global_position + Vector2(0.0, button.size.y/2.0))
