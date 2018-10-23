extends Position2D

signal target_selected(battler)

onready var anim_player = $Sprite/AnimationPlayer

var targets : Array
var target_active : Battler

func _ready():
	hide()

func select_target(battlers : Array) -> Battler:
	visible = true
	targets = battlers
	target_active = targets[0]
	global_position = target_active.global_position
	anim_player.play("wiggle")
	var selected_target : Battler = yield(self, "target_selected")
	hide()
	return selected_target

func move_to(node_2d : Battler):
	global_position = node_2d.global_position

func _input(event):
	if event.is_action_pressed("ui_accept"):
		emit_signal("target_selected", target_active)
	
	var index = targets.find(target_active)
	if event.is_action_pressed("ui_down"):
		target_active = targets[(index + 1) % targets.size()]
		move_to(target_active)
	if event.is_action_pressed("ui_up"):
		target_active = targets[(index - 1 + targets.size()) % targets.size()]
		move_to(target_active)
