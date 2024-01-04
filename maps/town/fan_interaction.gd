extends InteractionTemplateConversation

const TOKEN_CHECK_TIMELINE: = preload("res://maps/town/fan_of_four_tokens.dtl")
const FINISHED_QUEST_TIMELINE: = preload("res://maps/town/fan_of_four_finished.dtl")

@export var controller: GamepieceController

var _quest_state: = 0

@onready var _adoring_fan: = get_parent() as Gamepiece
#@onready var _controller: = get_parent().get_node("Controller") as GamepieceController
@onready var _popop: = $InteractionPopup as InteractionPopup


func _ready() -> void:
	super._ready()
	assert(_adoring_fan, "Gamepiece was not found, check the node path!")
	assert(controller, "Controller was not found, check the node path!")


func _execute() -> void:
	match _quest_state:
		1: timeline = TOKEN_CHECK_TIMELINE
		2: timeline = FINISHED_QUEST_TIMELINE
	
	# Check to see if we get a specific signal during the conversation.
	Dialogic.signal_event.connect(_on_signal_event_received)
	await super._execute()
	Dialogic.signal_event.disconnect(_on_signal_event_received)
	
	if _quest_state == 0:
		await _on_initial_conversation_finished()
		_quest_state = 1


func _on_initial_conversation_finished() -> void:
	controller.travel_to_cell(Vector2(23, 13))
	await _adoring_fan.arrived


func _on_signal_event_received(argument: String) -> void:
	if argument == "receive_wand":
		_quest_state = 2
		_popop.is_active = false
		
		var inventory: = Inventory.restore()
		inventory.remove(Inventory.ItemTypes.COIN, 4)
		inventory.add(Inventory.ItemTypes.BLUE_WAND)
