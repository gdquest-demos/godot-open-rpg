extends Node2D
class_name Board
# Uses the underlying PathFinder (AStar) to find routes.
#
# This is a visual representation of the world, using TileMaps. It also offers visual feedback to
# the player for accessible vs obstacle tiles, interactive encounters, and Party destination flag
# when Party is given order to walk.


onready var path_finder : PathFinder = $PathFinder
onready var size : Vector2 = path_finder.rect.size * path_finder.map.cell_size

enum Feedback { INVALID = -1, ACTOR, OBJECT, FLAG, FORBID, ALLOW }

var _feedback : TileMap = null
var _has_feedback_flag = false

# Tries to find a valid route starting at `from` (inclusive) and finishing at `to` (inclusive).
#
# Returns an Vector2 Array of points in global pixel coordinates.
func get_point_path(from: Vector2, to: Vector2) -> Array:
	from = path_finder.map.world_to_map(from)
	to = path_finder.map.world_to_map(to)
	var out : = []
	if from != to:
		var ps : = path_finder.get_point_path(from, to)
		for p in ps:
			out.push_back(path_finder.map.map_to_world(p))
	return out


func _ready() -> void:
	_feedback = $Feedback
	
	Events.connect("party_walk_started", self, "_on_Events_party_walk", ["started"])
	Events.connect("party_walk_finished", self, "_on_Events_party_walk", ["finished"])
	path_finder.setup($Encounters.get_children())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse and not _has_feedback_flag:
		var at : = path_finder.map.world_to_map(get_global_mouse_position())
		var type : int = Feedback.FORBID if at in path_finder.map.obstacles else Feedback.ALLOW
		_feedback_react(at, type)


func _on_Events_party_walk(msg: Dictionary = {}, which: String = "") -> void:
	_has_feedback_flag = which == "started" and "to" in msg
	var at : = Vector2()
	var type : int = Feedback.INVALID
	if _has_feedback_flag:
		at = path_finder.map.world_to_map(msg.to)
		type = Feedback.FLAG
	_feedback_react(at, type)


func _feedback_react(xy: Vector2, type: int) -> void:
	_feedback.clear()
	type != Feedback.INVALID and _feedback.set_cellv(xy, type)
