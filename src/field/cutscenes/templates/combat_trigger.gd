@tool
class_name CombatTrigger extends Trigger

@export var combat_arena: PackedScene

# An internal flag that tracks the outcome of a given combat instance. It is reset every time this
# trigger is run.
var _is_victory: = false


func _execute() -> void:
	CombatEvents.combat_initiated.emit(combat_arena)
	
	# The trigger wants to know if the player wins or loses combat, so we'll listen in for win/lose
	# signals. We only want the trigger to know about THIS combat, so we need to track the method
	# reference in order to disconnect it, since the callback will not be called on a loss.
	_is_victory = false
	CombatEvents.combat_won.connect(_on_combat_won)
	await CombatEvents.combat_finished
	CombatEvents.combat_won.disconnect(_on_combat_won)
	
	# We want to run post-combat events. In some cases, this may not involve much, such as playing a
	# game-over screen or removing an AI combat-starting gamepiece from the field.
	# In some cases, however, we'll want a dialogue to play or some creative event to occur if, for
	# example, the player lost a difficult but non-essential battle.
	if _is_victory:
		await _run_victory_cutscene()
	
	else:
		await _run_loss_cutscene() 


func _on_combat_won() -> void:
	_is_victory = true


func _run_victory_cutscene() -> void:
	await get_tree().process_frame
	print("Player won")


func _run_loss_cutscene() -> void:
	await get_tree().process_frame
	print("Player lost")
