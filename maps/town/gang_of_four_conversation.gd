extends InteractionTemplateConversation


func _on_dialogic_signal_event(argument: String) -> void:
	if argument == "coin_received":
		Inventory.restore().add(Inventory.ItemTypes.COIN)
