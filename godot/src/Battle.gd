extends CanvasLayer


var is_open = false setget set_is_open

var _animation_player : AnimationPlayer = null
var _transition : ColorRect = null
var _arena : Container = null
var _arena_action_party : YSort = null


func _ready() -> void:
	_animation_player = $AnimationPlayer
	_transition = $TransitionLayer/Transition
	_arena = $Arena
	_arena_action_party = $Arena/Action/Party
	
	Events.connect("dialog_button_proceed_pressed", _animation_player, "play", ["transition_in"])
	_arena.connect("visibility_changed", self, "_on_Arena_vsibility_changed")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_open:
		_animation_player.play("transition_out")


func _on_Arena_vsibility_changed() -> void:
	if _arena.visible:
		Events.emit_signal(
				"battle_started",
				{"battler_positions": _arena_action_party.get_children()})
	else:
		Events.emit_signal("battle_finished", {})


func set_is_open(state: bool) -> void:
	is_open = state