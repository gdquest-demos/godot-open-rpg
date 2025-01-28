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

@onready var _action_menus: = $PlayerActionUIBuilder as UIActionMenuBuilder
@onready var _battler_list: = $PlayerBattlerList as UIPlayerBattlerList


## Prepare the menus for use by assigning appropriate [Battler] data.
func setup(battler_data: BattlerList) -> void:
	_action_menus.setup(battler_data)
	_battler_list.setup(battler_data)
	
	battler_data.battlers_downed.connect(_battler_list.fade_out)
