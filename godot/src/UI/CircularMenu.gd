extends Control
class_name Skills


export(float) var radius : = 100.0
export(float, 0.0, 360.0) var arc_angle : = 90.0
export(float, 5.0) var open_button_time : = 1.0
export(float, 1.0) var open_button_delay : = 0.1
export(float, 5.0) var close_button_time : = 1.0
export(float, 1.0) var close_button_delay : = 0.1

var open : = false setget set_open

onready var _tween : Tween = $Tween
onready var _timer : Timer = $Timer
var _controls_rect_position : = []


func setup() -> void:
	visible = open
	var phi : = 270.0
	var controls_count : = get_controls_count()
	for control in get_controls():
		var control_angle : float = phi if controls_count < 2 else lerp(
				phi - arc_angle / 2.0, phi + arc_angle / 2.0,
				(get_control_index(control)
				/ (controls_count - 1.0 + (1.0 if int(arc_angle) % 360 == 0 else 0.0))))
		var x : = radius * cos(deg2rad(control_angle))
		var y : = radius * sin(deg2rad(control_angle))
		control.rect_scale = Vector2()
		_controls_rect_position.push_back(Vector2(x, y))


func open():
	_tween.stop_all()
	_timer.stop()
	_timer.wait_time = max(open_button_delay, 0.01)
	open = true
	visible = true
	for control in get_controls():
		control.rect_position = Vector2()
		control.rect_scale = Vector2()
		_tween.interpolate_property(
				control, 'rect_scale', control.rect_scale, Vector2(1.0, 1.0), open_button_time,
				Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
		_tween.interpolate_property(
				control, 'rect_position', control.rect_position,
				_controls_rect_position[get_control_index(control)], open_button_time,
				Tween.TRANS_CUBIC, Tween.EASE_IN)
		if open_button_delay != 0.0:
			_timer.start()
			yield(_timer, "timeout")
		_tween.start()


func close():
	_tween.stop_all()
	_timer.stop()
	_timer.wait_time = max(close_button_delay, 0.01)
	var controls : = get_controls()
	controls.invert()
	for control in controls:
		_tween.interpolate_property(
				control, 'rect_scale', control.rect_scale, Vector2(), close_button_time,
				Tween.TRANS_QUAD, Tween.EASE_IN)
		if close_button_delay != 0.0:
			_timer.start()
			yield(_timer, "timeout")
		_tween.start()
	yield(_tween, "tween_completed")
	open = false
	visible = false


func get_controls() -> Array:
	var controls = []
	for child in get_children():
		if child is Control:
			controls.push_back(child)
	return controls


func get_controls_count() -> int:
	return get_controls().size()


func get_control_index(control: Control) -> int:
	return control.get_index() - 2


func set_open(state: bool) -> void:
	open = state
	open() if open else close()


func _ready() -> void:
	setup()
