extends BattlerAI

var interface: Node


func choose_action(actor: Battler, battlers: Array = []):
	# Select an action to perform in combat
	# Can be based on state of the actor
	interface.open_actions_menu(actor)
	return yield(interface, "action_selected")


func choose_target(actor: Battler, action: CombatAction, battlers: Array = []):
	# Chooses a target to perform an action on
	interface.select_targets(battlers)
	return yield(interface, "targets_selected")
