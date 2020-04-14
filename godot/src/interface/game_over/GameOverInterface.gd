extends CanvasLayer
class_name GameOverInterface

signal restart_requested

onready var panel := $Panel as Panel
onready var tween := $Tween as Tween
onready var selection_arrow := $Panel/SelectionArrow as Control
onready var message_label := $Panel/VBoxContainer/Message as Label
onready var try_again_button := $Panel/VBoxContainer/Options/TryAgain as Button
onready var options := $Panel/VBoxContainer/Options

enum Reason { PARTY_DEFEATED }

const MESSAGES = {'party_defeated': 'Your party was defeated!'}

var buttons = []
var selected_button_index := 0


func _ready() -> void:
	buttons = options.get_children()
	_move_arrow()


func _unhandled_input(event) -> void:
	if not panel.visible:
		return
	if event.is_action_pressed("ui_up"):
		selected_button_index = max(selected_button_index - 1, 0)
		_move_arrow()
	elif event.is_action_pressed("ui_down"):
		selected_button_index = min(selected_button_index + 1, buttons.size() - 1)
		_move_arrow()
	elif event.is_action_pressed("ui_accept"):
		buttons[selected_button_index].emit_signal("pressed")


func _move_arrow() -> void:
	var move_to = _get_arrow_position(selected_button_index)
	tween.interpolate_property(
		selection_arrow,
		"rect_global_position",
		selection_arrow.rect_global_position,
		move_to,
		0.1,
		Tween.TRANS_QUART,
		Tween.EASE_OUT
	)
	tween.start()


func display(reason) -> void:
	match reason:
		Reason.PARTY_DEFEATED:
			message_label.text = MESSAGES['party_defeated']
	panel.show()


func hide() -> void:
	panel.hide()


func _on_Exit_pressed() -> void:
	get_tree().quit()


func _on_TryAgain_pressed():
	emit_signal("restart_requested")


func _on_Load_pressed():
	print("IMPLEMENT LOAD GAME FUNCTIONALITY")


func _get_arrow_position(button_index: int = 0) -> Vector2:
	return buttons[button_index].get_global_rect().position
