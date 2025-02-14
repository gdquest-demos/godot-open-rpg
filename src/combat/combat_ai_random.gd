## The base class responsible for AI-controlled Battlers.
##
## For now, this simply selects a random [BattlerAction] and picks a random target, if one is
## available.
class_name CombatAI extends Node

var _has_selected_action: = false


func setup(battler: Battler, battler_list: BattlerList) -> void:
	battler.ready_to_act.connect(
		(func _on_battler_ready_to_act(source: Battler, battlers: BattlerList) -> void:
			if not _has_selected_action:
				# Only a Battler with actions is able to act.
				if source.actions.is_empty():
					print("AI: no actions")
					return
				
				# Randomly choose an action.
				var action_index: = randi() % source.actions.size()
				var action: = source.actions[action_index]
				print("AI: Found action")
				
				# Randomly choose a target.
				var possible_targets: = action.get_possible_targets(source, battlers)
				var targets: Array[Battler] = []
				print("AI: look for targets")
				if action.targets_all():
					targets = possible_targets
					print("AI: target all")
				else:
					var target_index: = randi() % possible_targets.size()
					targets.append(possible_targets[target_index])
					print("AI: target ", possible_targets[target_index].name)
				
				# If there are targets, register the action.
				if not targets.is_empty():
					print("AI: register action")
					_has_selected_action = true
					CombatEvents.action_selected.emit(action, source, targets)
				else:
					print("AI: no targets")
					).bind(battler, battler_list)
	)
	
	battler.action_finished.connect(
		func _on_battler_action_finished() -> void:
			_has_selected_action = false
	)
