extends Area2D
# An object with which the Party (Player) can interact on the Board.
#
# It doesn't do anything other than play an animation when Party leader is adjacent to it
# and send signals to other systems. Its purpose is to be detected by the Party leader.
#
# Check Party, Member & Walk behavior scripts for more information on being Detected.
#
# Notes
# -----
# For future proof, this Node is added to "encounters" group. This is used when trying to detect
# encounters in Members' Walk behavior to potentially distinguish from other Area2D object types.


var _icon : Sprite = null
var _animation_player : AnimationPlayer = null
var _has_encountered_party : = false


func _ready() -> void:
	_icon = $Icon
	_animation_player = $AnimationPlayer
	
	connect("input_event", self, "_on_Area_input_event")
	connect("mouse_entered", Events, "emit_signal", ["encounter_probed", {encounter = self}])
	connect("mouse_exited", Events, "emit_signal", ["encounter_probed", {encounter = null}])
	Events.connect("party_walk_started", self, "_on_Events_party_walk", ["started"])
	Events.connect("party_walk_finished", self, "_on_Events_party_walk", ["finished"])


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("trigger") and _has_encountered_party:
		Events.emit_signal("triggered", {encounter_icon = _icon.texture})
		_animation_player.seek(0, true)
		_animation_player.stop()


func _on_Area_input_event(viewport: Node, event: InputEvent, idx: int) -> void:
	if event.is_action_pressed("tap") and _has_encountered_party:
		Events.emit_signal("triggered", {encounter_icon = _icon.texture})
		_animation_player.seek(0, true)
		_animation_player.stop()


func _on_Events_party_walk(msg: Dictionary = {}, which: String = "") -> void:
	_has_encountered_party = (
			which != "started"
			and which == "finished"
			and msg.get("encounter") == self)
	_animation_player.play("dialog_bubble") if _has_encountered_party else _animation_player.play("<BASE>")