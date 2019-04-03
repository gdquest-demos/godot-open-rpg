extends Control
class_name StatBar

signal button_focused(cost)
signal button_unfocused
signal action_selected(action)

onready var bar = $Column/TextureProgress
onready var label = $Column/LifeLabel

var max_value : int = 0 setget set_max_value
var value : int = 0 setget set_value

export var LABEL_ABOVE : bool
export var HIDE_ON_DEPLETED : bool

func _ready() -> void:
	if LABEL_ABOVE:
		label.raise()

func set_max_value(new_value) -> void:
	max_value = new_value
	bar.max_value = new_value
	label.display(value, new_value)

func set_value(new_value) -> void:
	value = new_value
	bar.value = new_value
	label.display(new_value, max_value)
	if HIDE_ON_DEPLETED and value == 0:
		hide()

func initialize(battler : Battler) -> void:
	_connect_value_signals(battler)

func connect_preview(menu : Control) -> void:
	menu.connect("button_focused", self, "_on_button_focused")
	menu.connect("button_unfocused", self, "_on_button_unfocused")
	menu.connect("action_selected", self, "disconnect_preview", [menu])
	
#action passed to this function is unused, but is always passed with the signal
func disconnect_preview(action: CombatAction, menu : Control) -> void:
	menu.disconnect("button_focused", self, "_on_button_focused")
	menu.disconnect("button_unfocused", self, "_on_button_unfocused")
	
func _connect_value_signals(battler : Battler) -> void:
	print("Signals not connected in: " + name)

func _on_value_changed(new_value, old_value) -> void:
	self.value = new_value
	
func _on_button_focused(cost) -> void:
	pass
	
func _on_button_unfocused() -> void:
	pass

func _on_value_depleted() -> void:
	if HIDE_ON_DEPLETED:
		hide()
