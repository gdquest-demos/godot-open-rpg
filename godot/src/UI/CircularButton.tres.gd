extends Control


var _animation_player : AnimationPlayer = null
var _background : TextureButton = null
var _tooltip : Control = null


func _ready() -> void:
	_animation_player = $AnimationPlayer
	_background = $Background
	_tooltip = $Tooltip

	_background.connect("mouse_entered", _tooltip, "set_visible", [true])
	_background.connect("mouse_entered", _animation_player, "play", ["hover"])
	_background.connect("mouse_entered", _animation_player, "queue", ["turn"])
	_background.connect("mouse_entered", self, "set_draw_behind_parent", [false])
	_background.connect("mouse_exited", _tooltip, "set_visible", [false])
	_background.connect("mouse_exited", _animation_player, "play", ["<BASE>"])
	_background.connect("mouse_exited", self, "set_draw_behind_parent", [true])
