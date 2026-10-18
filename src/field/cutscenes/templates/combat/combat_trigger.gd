@tool
class_name CombatTrigger extends Trigger

@export var combat_arena: PackedScene


func _execute() -> void:
	# TODO: track persistence elsewehere.
	Dialogic.VAR.set_variable("Town.GhostDefeated", true)
	
	# Let other systems know that a combat has been triggered and then wait for its outcome.
	FieldEvents.combat_triggered.emit.call_deferred(combat_arena)


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
