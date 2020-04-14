tool
extends TextureProgress

export (Color) var COLOR_FULL
export (Color) var COLOR_NORMAL
export (Color) var COLOR_LOW
export (Color) var COLOR_CRITICAL

export (float, 0, 1) var THRESHOLD_LOW = 0.3
export (float, 0, 1) var THRESHOLD_CRITICAL = 0.1

var color_active = COLOR_NORMAL


func _on_Bar_maximum_changed(maximum):
	max_value = maximum


func animate_value(start, end):
	$Tween.interpolate_property(self, "value", start, end, 0.5, Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()


func update_color(new_value):
	var new_color
	if new_value > THRESHOLD_LOW * max_value:
		if new_value < max_value:
			new_color = COLOR_NORMAL
		else:
			new_color = COLOR_FULL
	elif new_value > THRESHOLD_CRITICAL * max_value:
		new_color = COLOR_LOW
	else:
		new_color = COLOR_CRITICAL

	if new_color == color_active:
		return
	color_active = new_color
	$Tween.interpolate_property(
		self, "modulate", modulate, new_color, 0.4, Tween.TRANS_QUART, Tween.EASE_OUT
	)
	$Tween.start()
