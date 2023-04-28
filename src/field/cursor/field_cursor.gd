## Handles mouse/touch events for the field gamestate.
##
## The field cursor's role is to determine whether or not the input event occurs over a pathable
## cell and how that particular cell should be highlighted.
class_name FieldCursor
extends TileMap

signal focus_changed(old_focus: Vector2i, new_focus: Vector2i)
signal selected(selected_cell: Vector2i)

const CURSOR_LAYER: = 0 # Could have a layer for different cursor colours? Red for danger, etc.
const CURSOR_TYPE: = {
	"Default": Vector2(1, 5),
	"Path": Vector2(0, 5)
}

## The cursor may focus on any cell from those included in valid_cells.
## The valid cell list may be used to change what is 'highlightable' at any given moment (e.g. an
## ability that only affects neighbouring cells or limiting movement to a given direction).
## An empty valid_cells list will allow the cursor to select any cell.
var valid_cells: Array[Vector2i] = []:
	set = set_valid_cells

@export var grid: Grid
var highlight_strategy: CursorHighlightStrategy = null:
	set = set_highlight_strategy

var _focus: = Grid.INVALID_CELL:
	set = _set_focus


func _ready() -> void:
	assert(grid, "\n%s::intialize error - The Grid object is invalid!" % name)
	
	highlight_strategy = CursorHighlightDefault.new()


func set_valid_cells(cells: Array[Vector2i]) -> void:
	valid_cells = cells
	
	if _is_cell_invalid(_focus):
		_set_focus(Grid.INVALID_CELL)


func set_highlight_strategy(new_strategy: CursorHighlightStrategy) -> void:
	highlight_strategy = new_strategy


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()
		_set_focus(_get_cell_under_mouse())
	
	elif event.is_action_released("select"):
		get_viewport().set_input_as_handled()
		
		selected.emit(_get_cell_under_mouse())
		FieldEvents.cell_selected.emit(_get_cell_under_mouse())


func _set_focus(value: Vector2i) -> void:
	if _is_cell_invalid(value):
		value = Grid.INVALID_CELL
	
	if value == _focus:
		return
	
	var old_focus: = _focus
	_focus = value
	
	clear()
	
	if highlight_strategy:
		highlight_strategy.highlight(self, _focus)
	
	focus_changed.emit(old_focus, _focus)
	FieldEvents.cell_highlighted.emit(_focus)


func _get_cell_under_mouse() -> Vector2i:
	# The mouse coordinates need to be corrected for any scale or position changes in the scene.
	var mouse_position: = ((get_global_mouse_position()-global_position) / global_scale)
	var cell_under_mouse: = grid.pixel_to_cell(mouse_position)
	
	if not grid.boundaries.has_point(cell_under_mouse):
		cell_under_mouse = Grid.INVALID_CELL
	
	return cell_under_mouse


func _is_cell_invalid(cell: Vector2i) -> bool:
	return not valid_cells.is_empty() and not cell in valid_cells
