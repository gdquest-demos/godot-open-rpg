extends YSort
class_name Party
# This can be thought of as the player object.
#
# It has multiple Members (child nodes) that it manages. The leader Member (child node with index
# position of 0) is special. He is given the Detect node which is a four RayCast2D system pointing
# South, West, North & East as expected. Apart from that the leader also gets the RemoteTransform
# which is used with the Camera. This has to be done to simplify Camera movement when cycling
# through Member positions. Without it, it would be a bit tricky to make the Camera move smoothly.
#
# The Detect scene is used by the Walk behavior to verify adjacent encounters. It does this so we
# have a way of identifying which encounter the Party... encounters. This tirggers some changes in
# the in other Systems like Dialog etc. (to be further explored).


const Detect : = preload("res://src/Party/Detect.tscn")

var _camera : Camera2D = null
var _detect : = Detect.instance()
var _remote_transform : = RemoteTransform2D.new()


func setup(board_size: Vector2) -> void:
	_remote_transform.remote_path = _camera.get_path()
	_camera.limit_right = board_size.x
	_camera.limit_bottom = board_size.y
	for member in get_members():
		member.setup(_detect, _remote_transform)


func get_member_count():
	return get_child_count() - 1


func get_members() -> Array:
	var members : = []
	for member in get_children():
		not member is Camera2D and members.push_back(member)
	return members


func get_member(idx: int) -> Node:
	var member : = get_child(idx) if idx >= 0 and idx < get_member_count() else null
	member = null if member is Camera2D else member
	return member


func get_member_by_position(p: Vector2) -> Node:
	var member : Node = null
	for m in get_members():
		if (m.position - p).length() < Utils.ERR:
			member = m
			break
	return member


func _ready() -> void:
	_camera = $Camera
	
	Events.connect("dialog_button_cycle_pressed", self, "_cycle")


func _unhandled_input(event: InputEvent) -> void:
	event.is_action_pressed("cycle") and _cycle()


# Cycles the Party Members so that the leader remains in same place after it has been swapped.
func _cycle() -> void:
	var leader : = get_member(0)
	if leader == null:
		return
	
	move_child(leader, get_member_count() - 1)
	leader.setup(_detect, _remote_transform)
	for member in get_members():
		member.walk([member.position, leader.position])
		member.setup(_detect, _remote_transform)
		leader = member
