extends Control

const ContextualAction = preload("CircularButton.tscn")

export(float, 0.0, 300.0) var radius : float = 190 setget set_radius
export(float, 0, 1.0) var spacing : float = 0.2 setget set_spacing
export(float, -1.0, 1.0) var offset : float = -0.1 setget set_offset

enum Layout { CENTERED = 0, CLOCKWISE = 1, COUNTER_CLOCKWISE = -1}
export(Layout) var layout : int = CENTERED

func _ready() -> void:
	initialize([{'name': 'Attack'}, {'name': 'Run'}, {'name': 'Reload'}, {'name': 'Attack'}, {'name': 'Run'}])

func initialize(actions : Array) -> void:
	"""
	Takes an array of actions to create the contextual menu entries
	"""
	for action in actions:
		var button = ContextualAction.instance()
		add_child(button)
		var target_position = _calculate_position(button, actions.size())
		button.initialize(action, target_position)

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
