# Player-controlled pawn.
# Set to Stop during pause
extends PawnActor
class_name PawnLeader

onready var destination_point := $DestinationPoint

var _path_current := PoolVector3Array()
var _direction := Vector2()


func _ready() -> void:
	destination_point.set_as_toplevel(true)
	destination_point.hide()


func _process(delta: float) -> void:
	if _path_current.size() > 0:
		var next_point := Vector2(_path_current[0].x, _path_current[0].y)
		_direction = next_point - game_board.world_to_map(global_position)
		_path_current.remove(0)

	if _direction != Vector2():
		update_look_direction(_direction)
		var target_position: Vector2 = game_board.request_move(self, _direction)
		if target_position:
			move_to(target_position)
		else:
			bump()

	if _path_current.size() == 0:
		destination_point.hide()
		_direction = Vector2()


func get_key_input_direction(event: InputEventKey) -> Vector2:
	return Vector2(
		int(event.is_action_pressed("ui_right")) - int(event.is_action_pressed("ui_left")),
		int(event.is_action_pressed("ui_down")) - int(event.is_action_pressed("ui_up"))
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		_direction = get_key_input_direction(event)
	elif (
		event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed
		or event is InputEventScreenTouch and event.pressed
	):
		_path_current = game_board.find_path(global_position, get_global_mouse_position())
		if _path_current.size() > 0:
			var pos := _path_current[_path_current.size() - 1]
			destination_point.position = game_board.map_to_world(Vector2(pos.x, pos.y))
			destination_point.show()
