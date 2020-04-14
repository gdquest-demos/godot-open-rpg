extends Node

class_name BattlerAI


func choose_action(actor: Battler, battlers: Array = []):
	# Select an action to perform in combat
	# Can be based on state of the actor
	pass


func choose_target(actor: Battler, action: CombatAction, battlers: Array = []):
	# Chooses a target to perform an action on
	pass
