@tool
extends Node2D

# The controller operates on its direct parent, which must be a gamepiece object.
var _gamepiece: Gamepiece

## An active controller will receive input events and process at idle and physics frames. An
## inactive controller will not.
var is_active: = false:
	set(value):
		is_active = value
		
		set_process(is_active)
		set_physics_process(is_active)
		set_process_input(is_active)
		set_process_unhandled_input(is_active)


func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	
	if not Engine.is_editor_hint():
		is_active = true


func _process(_delta: float) -> void:
	var input_direction: = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_direction:
		if not _gamepiece.is_moving():
			var target_cell: = Vector2i.ZERO
			
			# Unless using 8-direction movement, one movement axis must be preferred. 
			#	Default to the x-axis.
			if not is_zero_approx(input_direction.x):
				input_direction = Vector2(input_direction.x, 0)
			else:
				input_direction = Vector2(0, input_direction.y)
			target_cell = Gameboard.pixel_to_cell(_gamepiece.position) + Vector2i(input_direction)
			
			# Try to get a path to destination (will fail if cell is occupied)
			# If path is valid, move.


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _gamepiece:
		warnings.append("This object must be a child of a gamepiece!")
	
	return warnings


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		_gamepiece = get_parent() as Gamepiece
		update_configuration_warnings()
