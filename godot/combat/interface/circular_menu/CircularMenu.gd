extends Control

signal action_selected(action)

const ContextualAction = preload("CircularButton.tscn")

export(float, 0.0, 300.0) var radius : float = 190 setget set_radius
export(float, 0, 1.0) var spacing : float = 0.2 setget set_spacing
export(float, -1.0, 1.0) var offset : float = -0.1 setget set_offset

enum Layout { CENTERED = 0, CLOCKWISE = 1, COUNTER_CLOCKWISE = -1}
export(Layout) var layout : int = CENTERED

func initialize(actor : Battler) -> void:
	"""
	Creates a circular menu from a battler's actions
	"""
	var actions = actor.actions.get_actions()
	for action in actions:
		var active : bool = true
		if action is SkillAction:
			active = actor.can_use_skill(action.skill)

		var button = ContextualAction.instance()
		add_child(button)
		var target_position = _calculate_position(button, actions.size())
		button.initialize(action, target_position, active)
		button.connect("pressed", self, "_on_CircularButton_pressed", [action])

func open():
	show()
	var first_button = get_child(0)
	first_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_focus_next"):
		var next_button_index = (get_focus_owner().get_index() + 1) % get_child_count()
		get_child(next_button_index).grab_focus()
		accept_event()
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_focus_prev"):
		var next_button_index = (get_focus_owner().get_index() - 1 + get_child_count()) % get_child_count()
		get_child(next_button_index).grab_focus()
		accept_event()

func close():
	queue_free()

func _on_CircularButton_pressed(action):
	emit_signal("action_selected", action)
	close()

func _update() -> void:
	for button in get_children():
		button.rect_position = _calculate_position(button, get_child_count())

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
