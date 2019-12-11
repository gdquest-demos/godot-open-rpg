extends Node
# Ties together top level components & systems.
#
# Game waits for user input and calculates a valid position (via mouse tap) or move direction
# (via keybaoard). It then tries to move the Party to the calculated destination. It doesn't do
# anything itself, it just preapares the path (Vector2 Array) which is used in the underlying
# components.
#
# Board: path finding, the TileMaps, encounters, and mouse feedback.
# Party: can be viewed as the player. The party contains Members (who extend Actor) with attached
#        behaviors.
#
# Check child nodes attached scripts for further details on each component.


var _dialog_system_gui : Node = null
var _board : Board = null
var _party : Party = null
var _encounter_near_party : Area2D = null
var _encounter_under_mouse : Area2D = null


func _ready() -> void:
	_dialog_system_gui = $DialogSystem/GUI
	_board = $Board
	_party = $Party
	
	Events.connect("encounter_probed", self, "_on_Events_encounter_probed")
	for member in _party.get_members():
		member.connect("walked", self, "_on_PartyMember_walked")
	_party.setup(_board.size)


func _unhandled_input(event: InputEvent) -> void:
	var move_direction : = _get_direction(event)
	if event.is_action_pressed("tap"):
		_party_command({tap_position = _board.get_global_mouse_position()})
	elif not _dialog_system_gui.is_open and move_direction != Vector2():
		_party_command({move_direction = move_direction})


func _on_Events_encounter_probed(msg: Dictionary = {}) -> void:
	_encounter_under_mouse = msg.get("encounter")


func _on_PartyMember_walked(msg: Dictionary = {}) -> void:
	if msg.get("is_leader", false):
		_encounter_near_party = msg.encounter
		Events.emit_signal("party_walk_finished", msg)


func _party_command(msg: Dictionary = {}) -> void:
	var leader : = _party.get_member(0)
	if (leader == null
			and not "tap_position" in msg
			or _encounter_under_mouse != null
			and _encounter_near_party == _encounter_under_mouse):
		return
	
	var path : = _prepare_path(leader, msg)
	var destination : = _party_walk(leader, path)
	not path.empty() and Events.emit_signal("party_walk_started", {"to": destination})


# Based on the input message Dictionary (msg) that holds information either about the mouse tap
# position or the direction to move into, in case the keyboard was used, it calculates a path if
# possible. The path starts with `leader.position` and ends at `tap_position` if mouse is used or
# `leader.position + move_direction` if keyboard is used.
#
# Returns a Vector2 Array of path points if succesful, otherwise it resturns an empty Array.
func _prepare_path(leader: Actor, msg: Dictionary = {}) -> Array:
	var path : = []
	match msg:
		{"tap_position": var tap_position}:
			path = _board.get_point_path(leader.position, tap_position)
		{"move_direction": var move_direction}:
			if move_direction in _board.path_finder.possible_directions:
				var from : Vector2 = leader.position
				var to : = from + Utils.to_px(move_direction, _board.path_finder.map.cell_size)
				if not _board.path_finder.map.world_to_map(to) in _board.path_finder.map.obstacles:
					path.push_back(from)
					path.push_back(to)
	return path


# Moves the Party if possible. It first checks too ensure `destination` doesn't overlap with
# Party Members. If `destination` does overlap with a Party Member then the leader just swappes
# with the other Member.
#
# Returns the extracted `destination` from `path`.
func _party_walk(leader: Actor, path: Array) -> Vector2:
	var destination : Vector2 = path[path.size() - 1] if not path.empty() else Vector2()
	var swapped : = _try_swapping_party_members(leader, destination)
	not (swapped or leader.is_walking) and _members_walk(leader, path)
	return destination


# Checks for `destination` overlap with another Party Member. If it does, it swappes the `leader`
# with the other Party Member.
#
# It returns `true` if swap succeds, otherwise `false`.
func _try_swapping_party_members(leader: Actor, destination: Vector2) -> bool:
	var swapped = false
	var other : Actor = _party.get_member_by_position(destination)
	if other != null and other != leader and _party.get_member_count() != 1:
		leader.walk([leader.position, other.position])
		other.walk([other.position, leader.position])
		swapped = true
	return swapped


# Given the `path` it orders the Party Members to walk.
func _members_walk(leader: Actor, path: Array) -> void:
	for member in _party.get_members():
		if member != leader:
			path = [member.position] + path
			path.pop_back()
		member.walk(path)


func _get_direction(event: InputEvent) -> Vector2:
	return Vector2(
			event.get_action_strength("ui_right") - event.get_action_strength("ui_left"),
			event.get_action_strength("ui_down") - event.get_action_strength("ui_up"))
