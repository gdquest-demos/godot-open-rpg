extends Control

const ContextualAction = preload("ContextualAction.tscn")

export(float, 0.0, 300.0) var radius : float = 190 setget set_radius
export(float, 0, 1.0) var spacing : float = 0.2 setget set_spacing
export(float, -1.0, 1.0) var offset : float = -0.1 setget set_offset

enum Layout { CENTERED = 0, CLOCKWISE = 1, COUNTER_CLOCKWISE = -1}
export(Layout) var layout : int = CENTERED

func _ready() -> void:
	initialize([{'name': 'Attack'}, {'name': 'Run'}, {'name': 'Reload'}, {'name': 'Attack'}, {'name': 'Run'}])

func set_radius(new_value : float) -> void:
	radius = new_value
	_update_buttons_position()

func set_spacing(new_value : float) -> void:
	spacing = new_value
	_update_buttons_position()

func set_offset(new_value : float) -> void:
	offset = new_value
	_update_buttons_position()

func initialize(actions : Array) -> void:
	"""
	Takes an array of actions to create the contextual menu entries
	"""
	for index in range(actions.size()):
		var button = ContextualAction.instance()
		add_child(button)
		var action_rotation = spacing * index * layout
		button.initialize(actions[index], action_rotation)
	_update_buttons_position()

func _update_buttons_position() -> void:
	var button_count = get_child_count()
	# The calculation is different if the menu is centered over the character,
	# built clockwise, or counter-clockwise
	var spacing_angle = spacing * PI
	var start_offset_angle = offset * PI
	if layout == CENTERED:
		var centering_offset = spacing_angle / 2.0 * (button_count - 1)
		for button in get_children():
			var polar_angle = spacing_angle * button.get_index() - centering_offset
			button.rect_position = Vector2(0, -radius).rotated(polar_angle + start_offset_angle)
	else:
		for button in get_children():
			var polar_angle = spacing_angle * button.get_index() * layout
			button.rect_position = Vector2(0, -radius).rotated(polar_angle + start_offset_angle)
