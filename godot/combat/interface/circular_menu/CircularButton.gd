extends Control

signal pressed()

onready var animation_player : = $AnimationPlayer as AnimationPlayer
onready var tooltip : = $Tooltip as Control

var mouse_over : bool
var active : bool

func initialize(action : CombatAction, target_position : Vector2) -> void:
	rect_position = target_position
	tooltip.initialize(self, action)
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

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		emit_signal("pressed")
		accept_event()
		
