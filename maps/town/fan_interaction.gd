extends InteractionTemplateConversation

@export var controller: GamepieceController

@onready var _adoring_fan: = get_parent() as Gamepiece
@onready var _popup: = $InteractionPopup as InteractionPopup


func _ready() -> void:
	super._ready()
	assert(_adoring_fan, "Gamepiece was not found, check the node path!")
	assert(controller, "Controller was not found, check the node path!")


func _execute() -> void:
	await super._execute()
	
	# The quest's state is tracked by a Dialogic variable.
	# After speaking with the character for the first time, he should run to a new position so that
	# the player can speak with the other NPCs.
	if Dialogic.VAR.get_variable("TokenQuestStatus") == 1:
		await _on_initial_conversation_finished()


func _on_initial_conversation_finished() -> void:
	controller.travel_to_cell(Vector2(23, 13))
	await _adoring_fan.arrived


# This conversation only emits a signal once: when the player should receive the quest reward.
func _on_dialogic_signal_event(_argument: String) -> void:
	_popup.is_active = false
	
	var inventory: = Inventory.restore()
	inventory.remove(Inventory.ItemTypes.COIN, 4)
	inventory.add(Inventory.ItemTypes.BLUE_WAND)
