extends Actor
# This is a Party Member, part of the Player Party "pack".
#
# It extends actor so it can use Behaviors. By default it has a Walk behavior apart from the NoOp
# behavior which all Actors have. The Party leader (that is. the child node of Party with index
# position 0) also has a Bump behavior. This is configured in `setup`.

signal walked(msg)

const BehaviorBump : = preload("res://src/Party/Behaviors/Bump.tscn")

const BOARD_SKIN : = preload("res://assets/sprites/characters/map/godette.png")
const DIALOG_ICON : = preload("res://assets/sprites/characters/battle/godette.png")

export(StreamTexture) var dialog_icon : = DIALOG_ICON

var is_walking : = false
var is_leader : = false

var _battler : Battler = null
var _board_position : Position2D = null
var _board_skin : Sprite = null
var _leader_icon : Sprite = null


# Boilerplate for setting up appropriate node relationships with leader. It also claculates proper
# sprite placement on map so they allign to the "ground". The leader gets to have a star sprite
# visible: LeaderIcon, so it's distinguished on the Board.
func setup(detect: Node2D, remote_transform: RemoteTransform2D) -> void:
	is_leader = get_index() == 0
	if is_leader:
		register(BehaviorBump.instance())
		detect != null and add_child(detect)
		remote_transform != null and _board_position.add_child(remote_transform)
	else:
		unregister(get_behavior("bump"))
		detect != null and has_node(detect.name) and remove_child(detect)
		if remote_transform != null and _board_position.has_node(remote_transform.name):
			_board_position.remove_child(remote_transform)
	
	_leader_icon.visible = is_leader
	_board_skin.offset.y = 0.5 * (BOARD_SKIN.get_height() - _board_skin.texture.get_height())
	Events.emit_signal("party_member_setup",
			{party_member_idx = get_index(), party_member_icon = dialog_icon})


func walk(path: Array) -> void:
	(get_behavior("bump").run()
		if is_walking or path.empty()
		else get_behavior("walk").run({path = path}))


func _ready() -> void:
	_battler = $Battle/Battler
	_board_position = $Board
	_board_skin = $Board/Skin
	_leader_icon = $Board/LeaderIcon
	
	Events.connect("battle_started", self, "_on_Events_battle", ["started"])
	Events.connect("battle_finished", self, "_on_Events_battle", ["finished"])


func _on_Events_battle(msg: Dictionary = {}, which: String = "") -> void:
	match [msg, which]:
		[{"battler_positions": var battler_positions}, "started"]:
			var idx : = get_index()
			_battler.scale = battler_positions[idx].scale
			_battler.position = battler_positions[idx].position
			is_leader and _battler._skills.open()
		[_, "finished"]:
			is_leader and _battler._skills.close()
