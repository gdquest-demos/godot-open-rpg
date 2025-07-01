## Handles mouse/touch events for the field gamestate.
##
## The field cursor's role is to determine whether or not the input event occurs over a particular
## cell and how that cell should be highlighted.
class_name FieldCursor
extends TileMapLayer

## Emitted when the highlighted cell changes to a new value. An invalid cell is indicated by a value
## of [constant Gameboard.INVALID_CELL].
signal focus_changed(old_focus: Vector2i, new_focus: Vector2i)

## Emitted when a cell is selected via input event.
signal selected(selected_cell: Vector2i)

## The cell currently highlighted by the cursor.
##
## [br][br]A focus of [constant Gameboard.INVALID_CELL] indicates that there is no highlight.
var focus: = Gameboard.INVALID_CELL:
	set = set_focus


func _ready() -> void:
	FieldEvents.input_paused.connect(_on_input_paused)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()
		set_focus(_get_cell_under_mouse())
	
	elif event.is_action_released("select"):
		get_viewport().set_input_as_handled()
		
		selected.emit(_get_cell_under_mouse())
		FieldEvents.cell_selected.emit(_get_cell_under_mouse())


## Change the highlighted cell to a new value. A value of [constant Gameboard.INVALID_CELL] will
## indicate that there is no highlighted cell.
## [br][br][b]Note:[/b] Values will be limited to [member valid_cells] if valid_cells is not empty.
## Values outside of valid_cells will not be focused.
func set_focus(value: Vector2i) -> void:
	if value == focus:
		return
	
	var old_focus: = focus
	focus = value
	
	clear()
	
	if focus != Gameboard.INVALID_CELL:
		set_cell(focus, 0, Vector2i(1, 5), 0)
		#set_cell(0, focus, 0, Vector2(1, 5))
	
	focus_changed.emit(old_focus, focus)
	FieldEvents.cell_highlighted.emit(focus)


# Convert mouse/touch coordinates to a gameboard cell.
func _get_cell_under_mouse() -> Vector2i:
	# The mouse coordinates need to be corrected for any scale or position changes in the scene.
	var mouse_position: = ((get_global_mouse_position()-global_position) / global_scale)
	var cell_under_mouse: = Gameboard.pixel_to_cell(mouse_position)
	
	if not Gameboard.pathfinder.has_cell(cell_under_mouse):
		cell_under_mouse = Gameboard.INVALID_CELL
	
	return cell_under_mouse


func _on_input_paused(is_paused: bool) -> void:
	set_process_unhandled_input(!is_paused)
	
	if is_paused:
		set_focus(Gameboard.INVALID_CELL)
