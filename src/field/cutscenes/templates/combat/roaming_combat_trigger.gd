@tool
extends CombatTrigger


# If the player has defeated this 'roaming encounter', remove the encounter.
func _run_victory_cutscene() -> void:
	queue_free()


# If the player has lost to this 'roaming encounter', play the game-over screen.
func _run_loss_cutscene() -> void:
	await get_tree().process_frame
