extends Control

export var tooltip_margin : int = 25

func initialize(text : String, action_rotation : float, action_rect_size : Vector2) -> void:
	$Background/Label.text = text
	_find_position(rad2deg(action_rotation), action_rect_size)
	$Background/Label.connect('draw', self, '_fix_background')

func _fix_background() -> void:
	"""
	Increases the size of the horizontal size of the background image according to the text size
	"""
	if $Background.rect_size.x < $Background/Label.rect_size.x + tooltip_margin:
		$Background.rect_size.x = $Background/Label.rect_size.x + tooltip_margin
	$Background/Label.disconnect('draw', self, '_fix_background')

func _find_position(rot : float, action_rect_size : Vector2) -> void:
	"""
	Finds the position in which the tooltip should appear based on it's rotation from the menu's center
	"""
	var abs_rot = abs(rot)
	var new_pos : = rect_position
	if abs_rot >= 90 and abs_rot < 270:
		new_pos.y = abs(rect_position.y) + action_rect_size.y
	if abs_rot > 0 and abs_rot <= 180:
		new_pos.x = action_rect_size.x
	
	rect_position = new_pos
