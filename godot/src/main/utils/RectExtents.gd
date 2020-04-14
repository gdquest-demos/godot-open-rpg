# Represents and draws a bounding rectangle 
# centered around the center of its bottom edge
tool
extends Node2D

class_name RectExtents

export var size: Vector2 = Vector2(40.0, 40.0) setget set_size
export var color: Color = Color("#ff0ea7") setget set_color
export var offset: Vector2 setget set_offset

var _rect: Rect2


func set_offset(value: Vector2) -> void:
	offset = value
	_recalculate_rect()
	update()


func set_size(value: Vector2) -> void:
	size = value
	_recalculate_rect()
	update()


func _recalculate_rect():
	_rect = Rect2(-1.0 * size / 2 + offset, size)


func set_color(value: Color) -> void:
	color = value
	update()


func _draw() -> void:
	if not Engine.editor_hint:
		return
	draw_rect(_rect, color, false)


func has_point(point: Vector2) -> bool:
	var rect_global = Rect2(global_position + _rect.position, _rect.size)
	return rect_global.has_point(point)
