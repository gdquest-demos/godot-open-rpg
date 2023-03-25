@tool
## Draws the boundaries set by a [Grid] object.
##
## Used within the editor to illustrate which cells will be included in the pathfinder calculations.
extends Node2D

@export var grid: Grid:
	set(value):
		grid = value
		
		if grid:
			_boundaries = Rect2i(
				grid.boundaries.position * grid.cell_size,
				grid.boundaries.size * grid.cell_size
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


func _draw() -> void:
	if not grid:
		return
	
	draw_rect(_boundaries, boundary_color, false, line_width)
