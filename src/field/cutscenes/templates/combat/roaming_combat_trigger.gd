@tool
extends CombatTrigger

@onready var gamepiece: = get_parent() as Gamepiece


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not gamepiece:
		warnings.append("This object must be a child of a gamepiece!")
	
	return warnings


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		gamepiece = get_parent() as Gamepiece
		update_configuration_warnings()


# If the player has defeated this 'roaming encounter', remove the encounterable gamepiece.
func _run_victory_cutscene() -> void:
	if gamepiece:
		gamepiece.queue_free()


# If the player has lost to this 'roaming encounter', incur the game-over screen.
func _run_loss_cutscene() -> void:
	await get_tree().process_frame
