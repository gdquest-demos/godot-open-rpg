class_name CombatArena extends Control

@export var music: AudioStream


# TODO: This is included to allow leaving the combat state.
# In future releases, these signals will be emitted once battlers from one side have fallen.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("back"):
		CombatEvents.combat_lost.emit()
	
	elif event.is_action_released("interact"):
		CombatEvents.combat_won.emit()
