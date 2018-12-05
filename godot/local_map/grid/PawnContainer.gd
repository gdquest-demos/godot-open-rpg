extends Node2D

export var party_scene : PackedScene

const LEADER = preload("res://local_map/pawns/Actor.tscn")
const FOLLOWER = preload("res://local_map/pawns/Follower.tscn")

var party_members : = []
var party

func spawn_party(party : Object, spawn_position : Vector2) -> void:
	self.party = party
	var last_spawned_pawn = null
	for index in range(party.get_child_count()):
		last_spawned_pawn = spawn_new_pawn(spawn_position, last_spawned_pawn, party.get_child(index).name, index == 0)
		party_members.append(last_spawned_pawn)

func spawn_new_pawn(pos : Vector2, last_spawned : Object, name : String, is_leader : bool = false) -> Object:
	var new_pawn = LEADER.instance() if is_leader else FOLLOWER.instance()
	new_pawn.name = name
	if last_spawned != null:
		last_spawned.connect("moved", new_pawn, "_on_target_Pawn_moved")
	new_pawn.position = pos
	add_child(new_pawn)
	return new_pawn

func request_move(pawn, direction):
	return get_parent().request_move(pawn, direction)

func rebuild_party() -> void:
	var leader_pos = party_members[0].position
	for member in party_members:
		member.queue_free()
	party_members.clear()
	spawn_party(party, leader_pos)
