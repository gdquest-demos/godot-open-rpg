extends Control

onready var label = get_node("Background/Label")
onready var background = get_node("Background")
export var tooltip_margin: int = 25


func initialize(button: Control, action: CombatAction) -> void:
	label.text = action.name
	label.connect('draw', self, '_resize_background')
	update_position(button)


func _resize_background() -> void:
	# Updates the horizontal size of the background image according to the label's size
	# Called after Godot re-drew the label
	if background.rect_size.x < label.rect_size.x + tooltip_margin:
		background.rect_size.x = label.rect_size.x + tooltip_margin
	label.disconnect('draw', self, '_resize_background')


func update_position(button: Control) -> void:
	var button_center = button.rect_position + button.rect_size / 2.0
	var polar_angle = -cartesian2polar(button_center.x, button_center.y).y
	var new_pos := rect_position
	if polar_angle < 0.0:
		new_pos.y = abs(rect_position.y) + button.rect_size.y
	if -PI / 2.0 < polar_angle and polar_angle < PI / 2.0:
		new_pos.x = button.rect_size.x
	rect_position = new_pos
