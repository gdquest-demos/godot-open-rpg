# The builder handles the creation of player BattlerActions by coordinating action and target menus.
# These menus are created at runtime in response to UI signals that are triggered by player input.
class_name UIActionMenuBuilder extends Node2D

# The action menu scene that will be created whenever the player needs to select an action.
@export var action_menu_scene: PackedScene

# The targetting cursor scene that will be created whenever the player needs to choose targets.
@export var target_cursor_scene: PackedScene

# The action menu/targeting cursor are created/freed dynamically. We'll track the combat participant
# data so that it can be fed into the action menu and targeting cursor on creation.
var _battlers: BattlerManager

# The UI is responsible for relaying player input to the combat systems. In this case, we want to
# track which battler and action are currently selected, so that we may queue orders for player
# battlers once the player has selected an action and targets.
# One caveat is that the selected battler may die while the player is setting up an action, in which
# case we want the menus to close immediately.
var _selected_battler: Battler = null:
	set(value):
		if _selected_battler:
			_selected_battler.health_depleted.disconnect(_on_selected_battler_health_depleted)
		
		_selected_battler = value
		if _selected_battler == null:
			_selected_action = null
		
		else:
			_selected_battler.health_depleted.connect(_on_selected_battler_health_depleted)

var _selected_action: BattlerAction = null

# The action menu originates from a point set in the scene tree by the following Marker2D.
@onready var _menu_anchor: = $ActionMenuAnchor as Marker2D


func _ready() -> void:
	# If a player battler has been selected, the action menu should open so that the player may
	# choose an action.
	CombatEvents.player_battler_selected.connect(
		func _on_player_battler_selected(battler: Battler) -> void:
			_selected_battler = battler
			if _selected_battler:
				var action_menu = action_menu_scene.instantiate() as UIActionMenu
				_menu_anchor.add_child(action_menu)
				action_menu.battler = _selected_battler
				
				# The action builder will wait until the player selects an action or presses 'back'.
				# Selecting an action will trigger the following signal, whereas pressing 'back'
				# will close the menu directly and deselect the current battler.
				action_menu.action_selected.connect(
					_on_action_menu_action_selected.bind(action_menu))
	)
	
	# If a valid player action has been selected, the targeting cursor should allow the player to
	# pick a target from a variety of battlers.
	#CombatEvents.player_action_selected.connect(
		#func _on_player_action_selected(action: BattlerAction, source: Battler) -> void:
			#_selected_action = action
			#
			#var cursor: = target_cursor_scene.instantiate() as UIBattlerTargetingCursor
			#add_child(cursor)
			#
			#cursor.targets = action.get_possible_targets(source, _battlers)
	#)
	
	# If valid targets have been selected, the player may issue an order to the Battler for it to
	# play out whenever its turn arrives.
	#CombatEvents.player_targets_selected.connect(
		#func _on_player_targets_selected(targets: Array[Battler]):
			#if not targets.is_empty():
				#
				#
				## The player has properly queued an action. Return the UI to the state where the
				## player will pick a player Battler.
				#CombatEvents.player_battler_selected.emit(null)
	#)


# Keep track of combat participants for the target menu.
func setup(battler_data: BattlerManager) -> void:
	_battlers = battler_data


# If the Battler dies while selecting an action or targets, close the menus immediately.
func _on_selected_battler_health_depleted():
	CombatEvents.player_battler_selected.emit(null)


# Callback triggered by the player selecting an action from the action menu. A cursor is created to
# track which targets the player selects.
func _on_action_menu_action_selected(action: BattlerAction, action_menu: UIActionMenu) -> void:
	_selected_action = action
	
	# Create the cursor which will respond to player input and allow choosing a target.
	var cursor: = target_cursor_scene.instantiate() as UIBattlerTargetingCursor
	add_child(cursor)
	cursor.targets = action.get_possible_targets(_selected_battler, _battlers)
	
	# And connect to the cursor's signals that will indicate that targets have been chosen.
	# Note that the action menu is currently hidden, and will be reshown if the player opts to
	# press the 'back' input.
	cursor.targets_selected.connect(action_menu._on_targets_selected)
	cursor.targets_selected.connect(
		func _on_cursor_targets_selected(targets: Array[Battler]) -> void:
			if not targets.is_empty():
				# At this point, the player should have selected a valid action and assigned it
				# targets, so the action may be cached for whenever the battler is ready.
				CombatEvents.action_selected.emit(_selected_action, _selected_battler, targets)
				
				# The player has properly queued an action. Return the UI to the state where the
				# player will pick a player Battler.
				CombatEvents.player_battler_selected.emit(null)
	)
