# Container for all pawns on the map.
# Sorts pawns by their Y position,
# Spawns and rebuilds the player's party
extends YSort

export var party_scene: PackedScene

const Leader = preload("res://src/map/pawns/PawnLeader.tscn")
const Follower = preload("res://src/map/pawns/PawnFollower.tscn")

var party_members := []
var party


func spawn_party(game_board, party: Object) -> void:
	self.party = party
	var pawn_previous = null
	var party_size = min(get_child_count(), party.PARTY_SIZE) - 1
	for index in range(party_size):
		pawn_previous = spawn_pawn(party.get_child(index), game_board, pawn_previous, index == 0)
		party_members.append(pawn_previous)


func spawn_pawn(
	party_member: PartyMember, game_board: GameBoard, pawn_previous: Object, is_leader: bool = false
) -> Object:
	var new_pawn: PawnActor = Leader.instance() if is_leader else Follower.instance()
	new_pawn.name = party_member.name
	new_pawn.position = game_board.spawning_point.position
	new_pawn.initialize(game_board)
	if pawn_previous:
		pawn_previous.connect("moved", new_pawn, "_on_target_Pawn_moved")
	add_child(new_pawn)
	new_pawn.change_skin(party_member.get_pawn_anim())
	return new_pawn


func rebuild_party() -> void:
	var Leader_pos = party_members[0].position
	for member in party_members:
		member.queue_free()
	party_members.clear()
	spawn_party(party, Leader_pos)
