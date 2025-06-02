@tool
## Draws the boundaries set by a [Gameboard] object.
##
## Used within the editor to illustrate which cells will be included in the pathfinder calculations.
class_name DebugGameboardBoundaries extends Node2D

@export var gameboard_properties: GameboardProperties:
	set(value):
		gameboard_properties = value
		
		if gameboard_properties:
			_boundaries = Rect2i(
				gameboard_properties.extents.position * gameboard_properties.cell_size,
				gameboard_properties.extents.size * gameboard_properties.cell_size
			)
		
		queue_redraw()

@export var boundary_color: Color = Color.DARK_RED:
	set(value):
		boundary_color = value
		queue_redraw()

@export_range(0.5, 5.0, 0.1, "or_greater") var line_width: = 2.0:
	set(value):
		line_width = value
		queue_redraw()

var _boundaries: Rect2i


func _ready() -> void:
	if not Engine.is_editor_hint():
		hide()


func _draw() -> void:
	if not gameboard_properties:
		return
	
	draw_rect(_boundaries, boundary_color, false, line_width)
