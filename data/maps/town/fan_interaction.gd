extends InteractionTemplateConversation

@onready var _adoring_fan: = get_parent() as Gamepiece


func interact() -> void:
	Dialogic.timeline_ended.connect(_on_conversation_finished, CONNECT_ONE_SHOT)
	
	super.interact()


func _on_conversation_finished() -> void:
	_adoring_fan.travel_to_cell(Vector2(23, 13))
	await _adoring_fan.arrived
	print("Done")
