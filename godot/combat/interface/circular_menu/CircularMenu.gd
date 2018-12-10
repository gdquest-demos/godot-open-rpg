extends Control

signal action_selected(action)

const ContextualAction = preload("CircularButton.tscn")

onready var tween : = $Tween as Tween
onready var buttons : = $Buttons as Control

export(float, 0.0, 300.0) var radius : float = 190 setget set_radius
export(float, 0, 1.0) var spacing : float = 0.2 setget set_spacing
export(float, -1.0, 1.0) var offset : float = -0.1 setget set_offset
export(float, 0.01, 0.1) var animation_offset : float = 0.08
export(float, 0.1, 0.5) var animation_duration : float = 0.2

enum Layout { CENTERED = 0, CLOCKWISE = 1, COUNTER_CLOCKWISE = -1}
export(Layout) var layout : int = CENTERED

func initialize(actor : Battler) -> void:
	"""
	Creates a circular menu from a battler's actions
	"""
	var actions = actor.actions.get_actions()
	for action in actions:
		var button = ContextualAction.instance()
		buttons.add_child(button)
		var target_position = _calculate_position(button, actions.size())
		button.initialize(action, target_position)
		button.connect("pressed", self, "_on_CircularButton_pressed", [action])

func open() -> void:
	show()
	for button_index in buttons.get_child_count():
		var button = buttons.get_child(button_index)
		tween.interpolate_property(button, "rect_scale", Vector2(), button.unfocused_scale, animation_duration, Tween.TRANS_QUART, Tween.EASE_IN, animation_offset * button_index)
		tween.interpolate_property(button, "rect_position", Vector2(), button.target_position, animation_duration, Tween.TRANS_QUART, Tween.EASE_IN, animation_offset * button_index)
		tween.interpolate_property(button, "modulate", Color('#00ffffff'), Color('#ffffffff'), animation_duration, Tween.TRANS_QUART, Tween.EASE_OUT, animation_offset * button_index)
	tween.start()
	yield(tween, "tween_completed")
	var first_button = buttons.get_child(0)
	first_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_focus_next"):
		if tween.is_active():
			cancel_animation()
		var next_button_index = (get_focus_owner().get_index() + 1) % buttons.get_child_count()
		buttons.get_child(next_button_index).grab_focus()
		accept_event()
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_focus_prev"):
		if tween.is_active():
			cancel_animation()
		var next_button_index = (get_focus_owner().get_index() - 1 + buttons.get_child_count()) % buttons.get_child_count()
		buttons.get_child(next_button_index).grab_focus()
		accept_event()

func close() -> void:
	for button_index in buttons.get_child_count():
		var button = buttons.get_child(button_index)
		button.animation_player.stop()
		tween.interpolate_property(button, "rect_scale", button.rect_scale, Vector2(), animation_duration, Tween.TRANS_QUART, Tween.EASE_OUT, animation_offset * button_index)
		tween.interpolate_property(button, "rect_position", button.rect_position, Vector2(), animation_duration, Tween.TRANS_QUART, Tween.EASE_OUT, animation_offset * button_index)
		tween.interpolate_property(button, "modulate", Color('#ffffffff'), Color('#00ffffff'), animation_duration, Tween.TRANS_QUART, Tween.EASE_OUT, animation_offset * button_index)
	tween.start()
	yield(tween, "tween_completed")
	queue_free()

func cancel_animation() -> void:
	tween.stop_all()
	for button_index in buttons.get_child_count():
		var button = buttons.get_child(button_index)
		button.rect_scale = button.unfocused_scale
		button.rect_position = button.target_position
	var first_button = buttons.get_child(0)
	first_button.grab_focus()

func _on_CircularButton_pressed(action):
	yield(close(), "completed")
	emit_signal("action_selected", action)

func _update() -> void:
	if not is_inside_tree():
		return
	for button in buttons.get_children():
		button.rect_position = _calculate_position(button, buttons.get_child_count())

func _calculate_position(button, buttons_count : int) -> Vector2:
	"""
	Returns the button's position relative to the menu
	"""
	# The calculation is different if the menu is centered over the character,
	# built clockwise, or counter-clockwise
	var spacing_angle = spacing * PI
	var start_offset_angle = offset * PI
	var button_position : Vector2
	if layout == CENTERED:
		var centering_offset = spacing_angle / 2.0 * (buttons_count - 1)
		var angle = spacing_angle * button.get_index() - centering_offset + start_offset_angle
		button_position = Vector2(0, -radius).rotated(angle)
	else:
		var angle = spacing_angle * button.get_index() * layout + start_offset_angle
		button_position = Vector2(0, -radius).rotated(angle)
	return button_position

func set_radius(new_value : float) -> void:
	radius = new_value
	_update()

func set_spacing(new_value : float) -> void:
	spacing = new_value
	_update()

func set_offset(new_value : float) -> void:
	offset = new_value
	_update()
