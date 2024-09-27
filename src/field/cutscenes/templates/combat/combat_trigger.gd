@tool
class_name CombatTrigger extends Trigger

@export var combat_arena: PackedScene


func _execute() -> void:
	# Let other systems know that a combat has been triggered and then wait for its outcome.
	FieldEvents.combat_triggered.emit(combat_arena)
	
	var did_player_win: bool = await CombatEvents.combat_finished
	
	# The combat ends with a covered screen, and so we fix that here.
	Transition.clear.call_deferred(0.2)
	await Transition.finished
	
	# We want to run post-combat events. In some cases, this may not involve much, such as playing a
	# game-over screen or removing an AI combat-starting gamepiece from the field.
	# In some cases, however, we'll want a dialogue to play or some creative event to occur if, for
	# example, the player lost a difficult but non-essential battle.
	if did_player_win:
		await _run_victory_cutscene()
	
	else:
		await _run_loss_cutscene() 


## The following method may be overwridden to allow for custom behaviour following a combat victory.
## Examples include adding an item to the player's inventory, running a dialogue, removing an enemy
## [Gamepiece], etc.
func _run_victory_cutscene() -> void:
	await get_tree().process_frame


## The following method may be overwridden to allow for custom behaviour following a combat loss.
## In most cases this may result in a gameover, but in others it may run a cutscene, change some
## sort of event flag, etc.
func _run_loss_cutscene() -> void:
	await get_tree().process_frame
