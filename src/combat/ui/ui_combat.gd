## The combat UI coordinates player input during the combat game-state.
##
## The menus are largely signal driven, which are emitted according to player input. The player is
## responsible for issuing [BattlerAction]s to their respective [Battler]s, which are acted out in
## order by the [ActiveTurnQueue].[br][br]
##
## Actions are issued according to the following steps:[br]
##     - The player selects one of their Battlers from the [UIPlayerBattlerList].[br]
##     - A [UIActionMenu] appears, which allows the player to select a valid action.[br]
##     - Finally, potential targets are navigated using a [UIBattlerTargetingCursor].[br]
## The player may traverse the menus, going backwards and forwards through the menus as needed.
## Once the player has picked an action and targets, it is assigned to the queue by means of the
## [signal CombatEvents.action_selected] global signal.
class_name UICombat extends Control

## The action menu scene that will be created whenever the player needs to select an action.
@export var action_menu_scene: PackedScene

## The targetting cursor scene that will be created whenever the player needs to choose targets.
@export var target_cursor_scene: PackedScene

# UI elements - effects
@onready var animation: = $AnimationPlayer as AnimationPlayer
@onready var _effect_label_builder: = $EffectLabelBuilder as UIEffectLabelBuilder

# UI elements - player menus
@onready var _action_description: = $PlayerMenus/ActionDescription as UIActionDescription
@onready var _action_menu_anchor: = $PlayerMenus/ActionMenuAnchor as Control
@onready var _battler_list: = $PlayerMenus/PlayerBattlerList as UIPlayerBattlerList


func _ready() -> void:
	# If a player battler has been selected, the action menu should open so that the player may
	# choose an action.
	# If no battler is selected (i.e. it's time to execute the actions) then the menus will just be
	# hidden.
	CombatEvents.player_battler_selected.connect(
		(func _on_player_battler_selected(battler: Battler) -> void:
			if battler != null:
				choose_action(battler)
			)
	)


## Prepare the menus for use by assigning appropriate [BattlerRoster] data.
func setup(battler_data: BattlerRoster) -> void:
	_effect_label_builder.setup(battler_data)
	_battler_list.battlers = battler_data.get_player_battlers()


func choose_action(battler: Battler) -> void:
	# Instantiate the scene, stuff it full of action data, and show it on the screen.
	var action_menu = action_menu_scene.instantiate() as UIActionMenu
	_action_menu_anchor.add_child(action_menu)
	action_menu.setup(battler.actions)
	action_menu.is_active = true
	
	# Link the action menu to the action description bar, providing a description of the
	# highlighted action.
	action_menu.action_focused.connect(
		func _on_action_focused(action: BattlerAction) -> void:
			_action_description.description = action.description
	)
	
	# The action builder will wait until the player selects an action or presses 'back'.
	# Selecting an action will trigger the following signal, whereas pressing 'back' will try to
	# return action selection to the previous player Battler.
	action_menu.action_selected.connect(
		(func _on_action_selected(action: BattlerAction, selected_battler: Battler) -> void:
			if action != null:
				choose_targets.call_deferred(selected_battler, action)
			
			# Cache a null action, indicating that the player refused selection and is looking to
			# choose actions for the previous Battler.
			else:
				selected_battler.cached_action = null

			## Whether or not the player selected an action, we'll want to hide the menu.
			action_menu.queue_free()
			).bind(battler)
	)


func choose_targets(battler: Battler, action: BattlerAction) -> void:
	# Create the cursor which will respond to player input and allow choosing a target.
	var cursor = target_cursor_scene.instantiate() as UIBattlerTargetingCursor
	cursor.targets_all = action.targets_all()
	cursor.targets = action.get_possible_targets()
	add_child(cursor)
	
	# The player may either select targets or press the "back" button.
	# If targets were chosen, we'll assign the targets to the action and, finally, cache the action
	# on the selected Battler.
	# If the user pressed "back", we'll go back to the choose action state.
	cursor.targets_selected.connect(
		(func _on_targets_selected(targets: Array[Battler], selected_action: BattlerAction,
				selected_battler: Battler) -> void:
			if not targets.is_empty():
				_action_description.description = ""
				
				# Caching the action on the Battler will let the Combat state know to begin choosing
				# actions for the next Battler.
				selected_action.cached_targets = targets
				selected_battler.cached_action = selected_action
			
			else:
				choose_action(selected_battler)
			).bind(action, battler)
	)
