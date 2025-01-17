# The builder is responsible for the creation of the UI elements needed for the player to select 
# actions and their targets. This includes the action menu and the targetting cursor, both created
# in response to combat signals.
class_name UIActionMenuBuilder extends Node2D

# The action menu scene that will be created whenever the player needs to select an action.
@export var action_menu_scene: PackedScene

# The targetting cursor scene that will be created whenever the player needs to choose targets.
@export var target_cursor_scene: PackedScene

# The action menu/targeting cursor are created/freed dynamically. We'll track the combat participant
# data so that it can be fed into the action menu and targeting cursor on creation.
var _battlers: CombatTeamData

# The action menu originates from a point set in the scene tree by the following Marker2D.
@onready var _menu_anchor: = $ActionMenuAnchor as Marker2D


func _ready() -> void:
	# If a player battler has been selected, the action menu should open so that the player may
	# choose an action.
	CombatEvents.player_battler_selected.connect(
		func _on_player_battler_selected(battler: Battler) -> void:
			if battler:
				var action_menu = action_menu_scene.instantiate() as UIActionMenu
				_menu_anchor.add_child(action_menu)
				action_menu.battler = battler
	)
	
	# If a valid player action has been selected, the targetting cursor should allow the player to
	# pick a target from a variety of battlers.
	# The following is connected directly 
	CombatEvents.player_action_selected.connect(
		func _on_player_action_selected(action: BattlerAction, source: Battler) -> void:
			var cursor: = target_cursor_scene.instantiate() as UIBattlerTargetingCursor
			add_child(cursor)
			
			cursor.targets = action.get_possible_targets(source, _battlers)
	)


# Keep track of combat participants for the target menu.
func setup(battler_data: CombatTeamData) -> void:
	_battlers = battler_data
