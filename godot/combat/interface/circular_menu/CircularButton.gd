extends Button

onready var animation_player : = $AnimationPlayer as AnimationPlayer
onready var tooltip : = $Tooltip as Control
onready var button_icon : = $Background/Icon as TextureRect

var mouse_over : bool
var active : bool

func initialize(action : CombatAction, target_position : Vector2, active : bool) -> void:
	rect_position = target_position
	disabled = not active
	if disabled:
		modulate = Color("#555555")
	tooltip.initialize(self, action)
	button_icon.texture = action.icon
	connect('mouse_exited', self, '_on_mouse_exited')
	connect('mouse_entered', self, '_on_mouse_entered')

func enter_focus():
	raise()
	tooltip.show()
	animation_player.play('activate')
	yield(animation_player, "animation_finished")
	animation_player.play('active')

func exit_focus():
	tooltip.hide()
	animation_player.play('deactivate')

func _on_mouse_entered() -> void:
	enter_focus()

func _on_mouse_exited() -> void:
	exit_focus()

func _on_focus_entered() -> void:
	enter_focus()

func _on_focus_exited() -> void:
	exit_focus()
