extends PawnActor

class_name PawnLeader

enum INPUT_MODES {TOUCH, KEYBOARD}
var _input_mode : int = KEYBOARD setget set_input_mode
# Array of contiguous points to move to in game_board coordinates, provided by the game_board's pathfinder
var _path_current : = PoolVector3Array() 

func _process(delta):
	var direction : = Vector2()

	# Switch to keyboard mode if the player presses a key
	var key_input_direction = get_key_input_direction()
	if key_input_direction and _input_mode == TOUCH:
		self._input_mode = KEYBOARD
	if _input_mode == KEYBOARD:
		direction = key_input_direction
	# Otherwise calculate the direction to the next cell on the path
	elif _input_mode == TOUCH and len(_path_current) > 0:
		var next_point : = Vector2(_path_current[0].x, _path_current[0].y)
		direction = next_point - game_board.world_to_map(global_position)
		_path_current.remove(0)

	if direction == Vector2():
		return
	# Movement
	update_look_direction(direction)
	var target_position = game_board.request_move(self, direction)
	if target_position:
		move_to(target_position)
	else:
		bump()

func get_key_input_direction():
	return Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventScreenTouch:
		return
	self._input_mode = TOUCH
	_path_current = game_board.find_path(global_position, event.position)

func set_input_mode(value):
	assert value in [KEYBOARD, TOUCH]
	_input_mode = value
