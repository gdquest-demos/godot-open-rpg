## Handles mouse/touch events for the field gamestate.
##
## The field cursor's role is to determine whether or not the input event occurs over a particular
## cell and how that cell should be highlighted.
class_name FieldCursor
extends TileMap

# Emitted whenever [member is_active] changes.
signal is_active_changed

## Emitted when the highlighted cell changes to a new value. An invalid cell is indicated by a value
## of [constant Gameboard.INVALID_CELL].
signal focus_changed(old_focus: Vector2i, new_focus: Vector2i)

## Emitted when a cell is selected via input event.
signal selected(selected_cell: Vector2i)

enum Images { DEFAULT, INTERACT }

enum Sizes { NORMAL, SMALL, TINY }

## Use a default mouse texture to prevent a image-less mouse.
const DEFAULT_MOUSE_TEXTURE: = preload("res://assets/gui/cursors/cursor_default.png")

## The different mouse images are mapped to a dictionary that use an array of enum constants as
## keys. The keys include the image and size of the mouse image to be drawn according to the
## following format: [[enum Images], [enum Sizes]][br]
const TEXTURES: = {
	[Images.DEFAULT, Sizes.NORMAL]: preload("res://assets/gui/cursors/cursor_default.png"),
	[Images.DEFAULT, Sizes.SMALL]: preload("res://assets/gui/cursors/cursor_default_small.png"),
	[Images.DEFAULT, Sizes.TINY]: preload("res://assets/gui/cursors/cursor_default_tiny.png"),
	
	[Images.INTERACT, Sizes.NORMAL]: preload("res://assets/gui/cursors/cursor_interact.png"),
	[Images.INTERACT, Sizes.SMALL]: preload("res://assets/gui/cursors/cursor_interact_small.png"),
	[Images.INTERACT, Sizes.TINY]: preload("res://assets/gui/cursors/cursor_interact_tiny.png"),
}

## If the ratio of the window size to the target viewport dimensions (set in [ProjectSettings]) is
## smaller than this cutoff but larger than [constant TINY_MOUSE_CUTOFF], the small version of the
## current mouse image will be drawn. Otherwise, the full sized image will be drawn at the mouse
## position.
const SMALL_MOUSE_CUTOFF: = 0.6

## If the ratio of the window size to the target viewport dimensions (set in [ProjectSettings]) is
## smaller than this cutoff the tiny version of the current mouse image will be drawn.
const TINY_MOUSE_CUTOFF: = 0.3

## The [Gameboard] object used to convert touch/mouse coordinates to game coordinates. The reference
## must be valid for the cursor to function properly.
@export var gameboard: Gameboard

## Colliders matching the following mask will be used to determine which cursor image is drawn.
@export_flags_2d_physics var interaction_mask: = 0

## An active cursor will interact with the gameboard, whereas an inactive cursor will do nothing.
var is_active: = true:
	set(value):
		if not value == is_active:
			is_active = value
			if not is_active:
				set_focus(Gameboard.INVALID_CELL)
			
			set_process(is_active)
			set_physics_process(is_active)
			set_process_input(is_active)
			set_process_unhandled_input(is_active)
			
			is_active_changed.emit()

## The cursor may focus on any cell from those included in valid_cells.
## The valid cell list may be used to change what is 'highlightable' at any given moment (e.g. an
## ability that only affects neighbouring cells or limiting movement to a given direction).
## An empty valid_cells list will allow the cursor to select any cell.
var valid_cells: Array[Vector2i] = []:
	set = set_valid_cells

## The cell currently highlighted by the cursor.
##
## [br][br]A focus of [constant Gameboard.INVALID_CELL] indicates that there is no highlight.
var focus: = Gameboard.INVALID_CELL:
	set = set_focus

var mouse_image: = Images.DEFAULT:
	set(value):
		if value in Images.values():
			mouse_image = value
			_update_custom_mouse_image()

var mouse_size: = Sizes.NORMAL:
	set(value):
		if value in Sizes.values():
			mouse_size = value
			_update_custom_mouse_image()


# Used to determine the topmost object that will try to change the cursor image.
var _interaction_finder: CollisionFinder

# The target resolution's width set in project properties. Used when scaling the cursor to determine
# the current window scale factor.
@onready var _window_size_target_width: float \
	= ProjectSettings.get_setting("display/window/size/viewport_width")


func _ready() -> void:
	assert(gameboard, "\n%s::initialize error - Invalid Gameboard reference!" % name)
	
	get_window().size_changed.connect(_scale_cursor)
	_scale_cursor()
	
	mouse_image = Images.DEFAULT
	
	# The cursor must be disabled by cinematic mode by responding to the following signals:
	FieldEvents.cinematic_mode_enabled.connect(_on_cinematic_mode_enabled)
	FieldEvents.cinematic_mode_disabled.connect(_on_cinematic_mode_disabled)
	
	_interaction_finder = CollisionFinder.new(get_world_2d().direct_space_state, 0.2, 
		interaction_mask)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
#		get_viewport().set_input_as_handled()
		set_focus(_get_cell_under_mouse())
	
	elif event.is_action_released("select"):
		get_viewport().set_input_as_handled()
		
		selected.emit(_get_cell_under_mouse())
		FieldEvents.cell_selected.emit(_get_cell_under_mouse())


## Limit cursor selection to a particular subset of cells.
## [br][br][b]Note:[/b] Providing an empty array will allow any cell to be highlighted (negative to
## positive infinity). Default behaviour assumes that all cells are valid.
func set_valid_cells(cells: Array[Vector2i]) -> void:
	valid_cells = cells
	
	if _is_cell_invalid(focus):
		set_focus(Gameboard.INVALID_CELL)


## Change the highlighted cell to a new value. A value of [constant Gameboard.INVALID_CELL] will
## indicate that there is no highlighted cell.
## [br][br][b]Note:[/b] Values will be limited to [member valid_cells] if valid_cells is not empty.
## Values outside of valid_cells will not be focused.
func set_focus(value: Vector2i) -> void:
	if _is_cell_invalid(value):
		value = Gameboard.INVALID_CELL
	
	if value == focus:
		return
	
	var old_focus: = focus
	focus = value
	
	clear()
	
	if focus != Gameboard.INVALID_CELL:
		set_cell(0, focus, 0, Vector2(1, 5))
	
	focus_changed.emit(old_focus, focus)
	FieldEvents.cell_highlighted.emit(focus)


# Convert mouse/touch coordinates to a gameboard cell.
func _get_cell_under_mouse() -> Vector2i:
	# The mouse coordinates need to be corrected for any scale or position changes in the scene.
	var mouse_position: = ((get_global_mouse_position()-global_position) / global_scale)
	var cell_under_mouse: = gameboard.pixel_to_cell(mouse_position)
	
	if not gameboard.boundaries.has_point(cell_under_mouse):
		cell_under_mouse = Gameboard.INVALID_CELL
	
	return cell_under_mouse


# A wrapper for cell validity criteria.
func _is_cell_invalid(cell: Vector2i) -> bool:
	return not valid_cells.is_empty() and not cell in valid_cells


func _update_custom_mouse_image() -> void:
	var texture: Texture = TEXTURES.get([mouse_image, mouse_size], DEFAULT_MOUSE_TEXTURE)
	Input.set_custom_mouse_cursor(texture)


# Rescale the cursor depending on window size. This needs to be done as custom cursors are not
# scaled with the rest of the window content.
func _scale_cursor() -> void:
	var window_scale: = float(get_window().size.x) / _window_size_target_width
	if window_scale <= TINY_MOUSE_CUTOFF:
		mouse_size = Sizes.TINY
	elif window_scale <= SMALL_MOUSE_CUTOFF:
		mouse_size = Sizes.SMALL
	else:
		mouse_size = Sizes.NORMAL


# Check underneath the cursor for any objects that would change the mosue image.
func _find_interactables_under_cursor() -> void:
	var collisions: = _interaction_finder.search(get_global_mouse_position()-global_position)
	for collision in collisions:
		var image: = collision.collider.get("mouse_image") as Images
		if image:
			mouse_image = image
			return
	mouse_image = Images.DEFAULT


# The cursor should not affect the field while in cinematic mode.
func _on_cinematic_mode_enabled() -> void:
	is_active = false


func _on_cinematic_mode_disabled() -> void:
	is_active = true
