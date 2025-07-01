@tool
## Draws the boundaries set by a [Gameboard] object.
##
## Used within the editor to illustrate which cells will be included in the pathfinder calculations.
class_name DebugGameboardBoundaries extends Node2D

@export var gameboard_properties: GameboardProperties:
	set(value):
		gameboard_properties = value
		# For some reason, Godot 4.4.1 won't connect to gameboard_properties signals here, so its
		# done on _ready instead. This means that the scene may need to be loaded before the
		# debug boundaries will automatically update.
		_update_boundaries()

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
	if gameboard_properties != null:
		gameboard_properties.extents_changed.connect(_update_boundaries)
		gameboard_properties.cell_size_changed.connect(_update_boundaries)
	
	if not Engine.is_editor_hint():
		hide()


func _draw() -> void:
	if not gameboard_properties:
		return
	
	draw_rect(_boundaries, boundary_color, false, line_width)


func _update_boundaries() -> void:
	if gameboard_properties != null:
		_boundaries = Rect2i(
			gameboard_properties.extents.position * gameboard_properties.cell_size,
			gameboard_properties.extents.size * gameboard_properties.cell_size
		)
		
		queue_redraw()
