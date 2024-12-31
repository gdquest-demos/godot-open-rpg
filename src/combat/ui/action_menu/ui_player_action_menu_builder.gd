# Is responsible for the creation of the UI elements needed for the player to select actions.
# This includes the action menu and the targetting cursor, both created in response to combat
# signals.
class_name UIActionMenuBuilder extends Node2D

@export var action_menu_scene: PackedScene
@export var target_cursor_scene: PackedScene

var action_menu: UIActionMenu


func _ready() -> void:
	set_process_unhandled_input(false)
	
	# If a player battler has been selected, the action menu should open so that the player may
	# choose an action.
	CombatEvents.player_battler_selected.connect(
		func _on_player_battler_selected(battler: Battler) -> void:
			if battler:
				action_menu = action_menu_scene.instantiate() as UIActionMenu
				$ActionMenuAnchor.add_child(action_menu)
				action_menu.battler = battler
			
			set_process_unhandled_input(battler != null)
	)
	
	# If a valid player action has been selected, the targetting cursor should allow the player to
	# pick a target from a variety of battlers.
	# The following is connected directly 
	#CombatEvents.player_action_selected.connect(
		#func _on_turn_queue_player_targeting(_action: BattlerAction, 
				#possible_targets: Array[Battler]) -> void:
			#var cursor: = target_cursor_scene.instantiate() as UIBattlerTargetingCursor
			#add_child(cursor)
			#
			#cursor.setup(possible_targets)
	#)
