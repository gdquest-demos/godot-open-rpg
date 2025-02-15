## The base class responsible for AI-controlled Battlers.
##
## For now, this simply selects a random [BattlerAction] and picks a random target, if one is
## available.
class_name CombatAI extends Node

var _has_selected_action: = false


## Connect to the signals of a given [Battler]. The callback randomly chooses an action from the
## Battler's [member Battler.actions] and then randomly chooses a target.
func setup(battler: Battler, battler_list: BattlerList) -> void:
	battler.ready_to_act.connect(
		(func _on_battler_ready_to_act(source: Battler, battlers: BattlerList) -> void:
			if not _has_selected_action:
				# Only a Battler with actions is able to act.
				if source.actions.is_empty():
					return
				
				# Randomly choose an action.
				var action_index: = randi() % source.actions.size()
				var action: = source.actions[action_index]
				
				# Randomly choose a target.
				var possible_targets: = action.get_possible_targets(source, battlers)
				var targets: Array[Battler] = []
				if action.targets_all():
					targets = possible_targets
				else:
					var target_index: = randi() % possible_targets.size()
					targets.append(possible_targets[target_index])
				
				# If there are targets, register the action.
				if not targets.is_empty():
					_has_selected_action = true
					CombatEvents.action_selected.emit(action, source, targets)
				else:
					).bind(battler, battler_list)
	)
	
	battler.action_finished.connect(
		func _on_battler_action_finished() -> void:
			_has_selected_action = false
	)
