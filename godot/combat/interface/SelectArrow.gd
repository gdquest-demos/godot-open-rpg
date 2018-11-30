extends Control

signal target_selected(battler)

onready var anim_player = $Sprite/AnimationPlayer
onready var tween = $Tween

export var MOVE_DURATION : float = 0.1

var targets : Array
var target_active : Battler

func _ready():
	hide()

func select_targets(battlers : Array) -> Array:
	"""
	Currently the arrow only allows you to select one target
	Returns an array containing the target
	"""
	visible = true
	targets = battlers
	target_active = targets[0]
	rect_scale.x = 1.0 if target_active.party_member else -1.0
	rect_global_position = target_active.target_global_position
	anim_player.play("wiggle")
	grab_focus()
	var selected_target : Battler = yield(self, "target_selected")
	hide()
	if not selected_target:
		return []
	return [selected_target]

func move_to(battler : Battler):
	tween.interpolate_property(
		self,
		'rect_global_position', 
		rect_global_position,
		battler.target_global_position,
		MOVE_DURATION,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT)
	tween.start()

func _gui_input(event):
	if !visible:
		return
	
	if event.is_action_pressed("ui_accept"):
		emit_signal("target_selected", target_active)
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		emit_signal("target_selected", null)
		get_tree().set_input_as_handled()
	
	var index = targets.find(target_active)
	if event.is_action_pressed("ui_down"):
		target_active = targets[(index + 1) % targets.size()]
		move_to(target_active)
		get_tree().set_input_as_handled()
	if event.is_action_pressed("ui_up"):
		target_active = targets[(index - 1 + targets.size()) % targets.size()]
		move_to(target_active)
		get_tree().set_input_as_handled()
