# Animated circular button that supports both keys and mouse input
# Reacts to mouse hover and focus events
extends Button

onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var tooltip := $Tooltip as Control
onready var button_icon := $Background/Icon as TextureRect

var mouse_over: bool
var active: bool
var target_position: Vector2
var unfocused_scale: Vector2


func initialize(action: CombatAction, target_position: Vector2) -> void:
	# Places the Button on the screen, where the appear tween animation should end
	# Disables the button if the action isn't usable, for example
	# if the battler doesn't have enough mana
	unfocused_scale = rect_scale
	rect_scale = Vector2()
	self.target_position = target_position

	button_icon.texture = action.icon
	disabled = not action.can_use()
	if disabled:
		modulate = Color("#555555")
	tooltip.initialize(self, action)

	connect('mouse_entered', self, 'enter_focus')
	connect('mouse_exited', self, 'exit_focus')
	connect('focus_entered', self, 'enter_focus')
	connect('focus_exited', self, 'exit_focus')


func enter_focus():
	raise()
	tooltip.show()
	animation_player.play('activate')
	yield(animation_player, "animation_finished")
	animation_player.play('active')


func exit_focus():
	tooltip.hide()
	animation_player.play('deactivate')
