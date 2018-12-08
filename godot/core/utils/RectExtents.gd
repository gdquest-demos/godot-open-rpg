"""
Represents and draws a bounding rectangle 
centered around the center of its bottom edge
"""
tool
extends Node2D

class_name RectExtents

export var size : Vector2 setget set_size
export var offset : Vector2 setget set_offset
export var color : Color = Color("#ff0ea7") setget set_color

var _base_offset : Vector2

func set_size(value : Vector2) -> void:
	size = value
	_calculate_base_offset()
	update()

func set_offset(value : Vector2) -> void:
	offset = value
	_calculate_base_offset()
	update()

func set_color(value : Color) -> void:
	color = value
	update()

func _draw() -> void:
	if not Engine.editor_hint:
		return
	draw_rect(Rect2(_base_offset + offset, size), color, false)

func _calculate_base_offset():
	_base_offset = -1.0 * Vector2(size.x / 2.0, size.y)

func has_point(point : Vector2) -> bool:
	var as_rect = Rect2(global_position + _base_offset + offset, size)
	return as_rect.has_point(point)
