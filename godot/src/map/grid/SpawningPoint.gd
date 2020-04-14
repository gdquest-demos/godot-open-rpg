tool
extends Position2D

export var DRAW_COLOR := Color("#e231b6")


func _draw() -> void:
	if not Engine.editor_hint:
		return
	var size := Vector2(64, 64)
	var rect := Rect2(-size / 2, size)
	draw_rect(rect, DRAW_COLOR, false)
