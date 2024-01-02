extends InteractionTemplateConversation


func _execute() -> void:
	# Check to see if we get a specific signal during the conversation.
	Dialogic.signal_event.connect(_on_signal_event_received)
	await super._execute()
	Dialogic.signal_event.disconnect(_on_signal_event_received)


func _on_signal_event_received(argument: String) -> void:
	if argument == "coin_received":
		Inventory.restore().add(Inventory.ItemTypes.COIN)
