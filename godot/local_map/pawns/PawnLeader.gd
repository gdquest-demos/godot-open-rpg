extends PawnActor

class_name PawnLeader

onready var destination_point : = $DestinationPoint as Sprite

enum INPUT_MODES {TOUCH, KEYBOARD}
var _input_mode : int = INPUT_MODES.KEYBOARD setget set_input_mode
# Array of contiguous points to move to in game_board coordinates, provided by the game_board's pathfinder
var _path_current : = PoolVector3Array() 

func _ready() -> void:
	destination_point.set_as_toplevel(true)
	destination_point.hide()

func _process(delta):
	var direction : = Vector2()

	# Switch to keyboard mode if the player presses a key
	var key_input_direction = get_key_input_direction()
	if key_input_direction and _input_mode == INPUT_MODES.TOUCH:
		self._input_mode = INPUT_MODES.KEYBOARD
	if _input_mode == INPUT_MODES.KEYBOARD:
		direction = key_input_direction
	# Otherwise calculate the direction to the next cell on the path
	elif _input_mode == INPUT_MODES.TOUCH and len(_path_current) > 0:
		var next_point : = Vector2(_path_current[0].x, _path_current[0].y)
		direction = next_point - game_board.world_to_map(global_position)
		_path_current.remove(0)
		if _path_current.size() == 0:
			destination_point.hide()

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
	# Using touch emulation from mouse and vice-versa so we can code
	# with mouse events
	if not event is InputEventMouseButton:
		return
	self._input_mode = INPUT_MODES.TOUCH
	# InputEventMouse.global_position doesn't seem to work with the camera
	# so instead I'm using CanvasItem.get_global_mouse_position()
	_path_current = game_board.find_path(global_position, get_global_mouse_position())
	if _path_current.size() > 0:
		var pos = _path_current[_path_current.size()-1]
		destination_point.position = game_board.map_to_world(Vector2(pos.x, pos.y))
		destination_point.show()

func set_input_mode(value):
	assert value in [INPUT_MODES.KEYBOARD, INPUT_MODES.TOUCH]
	_input_mode = value
