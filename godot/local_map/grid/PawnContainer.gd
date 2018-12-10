extends Node2D

export var party_scene : PackedScene

const Leader = preload("res://local_map/pawns/Actor.tscn")
const Follower = preload("res://local_map/pawns/Follower.tscn")

var party_members : = []
var party

func spawn_party(party : Object, world_position : Vector2) -> void:
	self.party = party
	var pawn_previous = null
	var party_size = min(get_child_count(), party.PARTY_SIZE) - 1
	for index in range(party_size):
		pawn_previous = spawn_pawn(
			world_position, 
			pawn_previous, 
			party.get_child(index).name, 
			index == 0)
		party_members.append(pawn_previous)

func spawn_pawn(pos : Vector2, pawn_previous : Object, pawn_name : String, is_leader : bool = false) -> Object:
	var new_pawn = Leader.instance() if is_leader else Follower.instance()
	new_pawn.name = pawn_name
	new_pawn.position = pos
	if pawn_previous:
		pawn_previous.connect("moved", new_pawn, "_on_target_Pawn_moved")
	add_child(new_pawn)
	return new_pawn

func request_move(pawn, direction):
	return get_parent().request_move(pawn, direction)

func rebuild_party() -> void:
	var Leader_pos = party_members[0].position
	for member in party_members:
		member.queue_free()
	party_members.clear()
	spawn_party(party, Leader_pos)
