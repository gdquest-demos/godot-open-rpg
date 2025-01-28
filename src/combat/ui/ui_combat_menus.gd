## The player combat menus coordinate all player input during the combat game-state.
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
class_name UICombatMenus extends Control

# The action menu scene that will be created whenever the player needs to select an action.
@export var action_menu_scene: PackedScene

# The targetting cursor scene that will be created whenever the player needs to choose targets.
@export var target_cursor_scene: PackedScene

# The action menu/targeting cursor are created/freed dynamically. We'll track the combat participant
# data so that it can be fed into the action menu and targeting cursor on creation.
var _battlers: BattlerList

# The UI is responsible for relaying player input to the combat systems. In this case, we want to
# track which battler and action are currently selected, so that we may queue orders for player
# battlers once the player has selected an action and targets.
# One caveat is that the selected battler may die while the player is setting up an action, in which
# case we want the menus to close immediately.
var _selected_battler: Battler = null:
	set(value):
		_selected_battler = value
		if _selected_battler == null:
			_selected_action = null

# Keep track of which action the player is currently building. This is relevent whenever the player
# is choosing targets.
var _selected_action: BattlerAction = null

@onready var _action_menu_anchor: = $ActionMenuAnchor as Node2D
@onready var _battler_list: = $PlayerBattlerList as UIPlayerBattlerList


## Prepare the menus for use by assigning appropriate [Battler] data.
func setup(battler_data: BattlerList) -> void:
	_battlers = battler_data
	_battler_list.setup(_battlers)
	
	_battlers.battlers_downed.connect(_battler_list.fade_out)
	
	# If a player battler has been selected, the action menu should open so that the player may
	# choose an action.
	CombatEvents.player_battler_selected.connect(
		func _on_player_battler_selected(battler: Battler) -> void:
			_selected_battler = battler
			if _selected_battler:
				_create_action_menu()
	)
	
	# If a player Battler dies while the player is selecting an action or choosing targets, signal
	# that the targeting cursor/menu should close.
	for battler in battler_data.player_battlers:
		battler.health_depleted.connect(
			(func _on_player_battler_health_depleted(downed_battler: Battler):
				if downed_battler == _selected_battler:
					CombatEvents.player_battler_selected.emit(null)).bind(battler)
		)


func _create_action_menu() -> void:
	assert(_selected_battler, "Trying to create the action menu without a selected Battler!")
	
	var action_menu = action_menu_scene.instantiate() as UIActionMenu
	_action_menu_anchor.add_child(action_menu)
	action_menu.battler = _selected_battler
	
	# The action builder will wait until the player selects an action or presses 'back'.
	# Selecting an action will trigger the following signal, whereas pressing 'back'
	# will close the menu directly and deselect the current battler.
	action_menu.action_selected.connect(
		func _on_action_selected(action: BattlerAction):
			_selected_action = action
			_create_targeting_cursor()
	)


func _create_targeting_cursor() -> void:
	assert(_selected_action, "Trying to create the targeting cursor without a selected action!")
	
	# Create the cursor which will respond to player input and allow choosing a target.
	var cursor: = target_cursor_scene.instantiate() as UIBattlerTargetingCursor
	add_child(cursor)
	cursor.targets = _selected_action.get_possible_targets(_selected_battler, _battlers)
	
	# And connect to the cursor's signals that will indicate that targets have been chosen.
	cursor.targets_selected.connect(
		func _on_cursor_targets_selected(targets: Array[Battler]) -> void:
			if not targets.is_empty():
				# At this point, the player should have selected a valid action and assigned it
				# targets, so the action may be cached for whenever the battler is ready.
				CombatEvents.action_selected.emit(_selected_action, _selected_battler, targets)
				
				# The player has properly queued an action. Return the UI to the state where the
				# player will pick a player Battler.
				CombatEvents.player_battler_selected.emit(null)
			
			else:
				_selected_action = null
				_create_action_menu()
	)
