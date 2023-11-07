extends InteractionTemplateConversation

@onready var _adoring_fan: = get_parent() as Gamepiece
@onready var _controller: = get_parent().get_node("Controller") as GamepieceController


func _ready() -> void:
	super._ready()
	assert(_adoring_fan, "Gamepiece was not found, check the node path!")
	assert(_controller, "Controller was not found, check the node path!")


func interact() -> void:
	Dialogic.timeline_ended.connect(_on_conversation_finished, CONNECT_ONE_SHOT)
	
	super.interact()


func _on_conversation_finished() -> void:
	_controller.travel_to_cell(Vector2(23, 13))
	await _adoring_fan.arrived
	print("Done")
