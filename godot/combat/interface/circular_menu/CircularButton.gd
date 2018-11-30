extends Control

onready var animation_player : = $AnimationPlayer as AnimationPlayer
onready var tooltip : = $Tooltip as Control

var mouse_over : bool
var active : bool

func initialize(action, action_rotation : float) -> void:
	tooltip.initialize(action.name, action_rotation, rect_size)

func _ready() -> void:
	connect('mouse_exited', self, '_on_mouse_exited')
	connect('mouse_entered', self, '_on_mouse_entered')

func _on_mouse_entered() -> void:
	raise()
	tooltip.show()
	animation_player.play('activate')
	yield(animation_player, "animation_finished")
	animation_player.play('active')

func _on_mouse_exited() -> void:
	tooltip.hide()
	animation_player.play('deactivate')
