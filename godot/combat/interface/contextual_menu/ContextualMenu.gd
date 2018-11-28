extends Control

const CONTEXTUAL_ACTION = preload("res://combat/interface/contextual_menu/ContextualAction.tscn")

export var radius : int = 128 setget set_radius
export(float, 0, 3.0) var action_spacing : float = 0.75 setget set_action_spacing
export var circle_to_right : bool = true setget set_circle_to_right

var direction : int = 1

func _ready() -> void:
	#TODO: Remove this, just for testing
	initialize([{'name': 'Attack'}, {'name': 'Run'}, {'name': 'Reload'}, {'name': 'Attack'}, {'name': 'Run'}, {'name': 'Reload'}])

func set_circle_to_right(new_value : bool) -> void:
	circle_to_right = new_value
	direction = 1 if circle_to_right else -1

func set_radius(new_value : int) -> void:
	radius = new_value
	_recalculate_actions_positions()

func set_action_spacing(new_value : float) -> void:
	action_spacing = new_value
	_recalculate_actions_positions()

func initialize(actions : Array) -> void:
	"""
	Takes an array of actions to create the contextual menu entries
	"""
	for action_index in range(actions.size()):
		var new_action = CONTEXTUAL_ACTION.instance()
		var action_rotation = action_spacing * action_index * direction
		new_action.rect_position = _get_action_position(action_index)
		add_child(new_action)
		new_action.initialize(actions[action_index], action_rotation)

func _get_action_position(index : int) -> Vector2:
	return Vector2(0, -radius).rotated(action_spacing * index * direction)

func _recalculate_actions_positions() -> void:
	for action_index in range(get_child_count()):
		var action = get_child(action_index)
		action.rect_position = _get_action_position(action_index)
