extends CanvasLayer
# DialogSystem GUI that updates itself when DefaultViewSystem Party members get cycled.


var is_open : = false setget set_is_open

var _container : Container = null
var _animation_player : AnimationPlayer = null
var _button_cycle : Button = null
var _button_move_away : Button = null
var _button_proceed : Button = null
var _encounter : TextureRect = null
var _slots : Array = []


func _ready() -> void:
	_container = $Container
	_animation_player = $AnimationPlayer
	_button_cycle = $Container/SlideContainer/PanelContainer/VBoxContainer/HBoxContainer/ButtonCycle
	_button_move_away = $Container/SlideContainer/PanelContainer/VBoxContainer/HBoxContainer/ButtonMoveAway
	_button_proceed = $Container/SlideContainer/PanelContainer/VBoxContainer/HBoxContainer/ButtonProceed
	_encounter = $Container/SlideContainer/EncounterContainer/Encounter
	_slots = $Container/SlideContainer/PartyContainer.get_children()
	
	_button_cycle.connect("pressed", Events, "emit_signal", ["dialog_button_cycle_pressed"])
	_button_move_away.connect("pressed", _animation_player, "play", ["slide_out"])
	_button_proceed.connect("pressed", _animation_player, "play", ["slide_out"])
	_button_proceed.connect("pressed", Events, "emit_signal", ["dialog_button_proceed_pressed"])
	Events.connect("party_member_setup", self, "_on_Events")
	Events.connect("triggered", self, "_on_Events")
	
	_slots.invert()


func _on_Events(msg: Dictionary = {}) -> void:
	match msg:
		{"encounter_icon": var encounter_icon}:
			_encounter.texture = encounter_icon
			not is_open and _animation_player.play("slide_in")
		{"party_member_idx": var party_member_idx, "party_member_icon": var party_member_icon}:
			party_member_idx < _slots.size() and _slots[party_member_idx].setup(party_member_icon)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_open:
		_animation_player.play("slide_out")


func set_is_open(state: bool) -> void:
	is_open = state