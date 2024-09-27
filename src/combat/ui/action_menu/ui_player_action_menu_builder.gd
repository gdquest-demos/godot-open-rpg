# Is responsible for the creation of the UI elements needed for the player to select actions.
# This includes the action menu and the targetting cursor, both created in response to combat
# signals.
class_name UIActionUIBuilder extends Control

@export var action_menu_scene: PackedScene
@export var target_cursor_scene: PackedScene


func _ready() -> void:
	# If a player battler has been selected, the action menu should open so that the player may
	# choose an action.
	CombatEvents.player_battler_selected.connect(
		func _on_player_battler_selected(battler: Battler) -> void:
			var action_menu: = action_menu_scene.instantiate() as UIActionMenu
			add_child(action_menu)
			
			action_menu.open(battler)
	)
	
	# If a valid player action has been selected, the targetting cursor should allow the player to
	# pick a target from a variety of battlers.
	# The following is connected directly 
	CombatEvents.player_action_selected.connect(
		func _on_turn_queue_player_targeting(_action: BattlerAction, 
				possible_targets: Array[Battler]) -> void:
			var cursor: = target_cursor_scene.instantiate() as UIBattlerTargetingCursor
			add_child(cursor)
			
			cursor.setup(possible_targets)
	)
