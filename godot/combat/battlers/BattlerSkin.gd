extends Position2D

export var TURN_START_MOVE_DISTANCE : float = 40.0
export var TWEEN_DURATION : float = 0.3

onready var tween = $Tween
onready var anim = $AnimationPlayer
var battler_anim : BattlerAnim
onready var position_start : Vector2

var blink : bool = false setget set_blink

func _ready():
	for child in get_children():
		if child is BattlerAnim:
			battler_anim = child
			break

func move_forward():
	var direction = Vector2(-1.0, 0.0) if owner.is_in_group("party") else Vector2(1.0, 0.0)
	tween.interpolate_property(
		self,
		'position',
		position_start,
		position_start + TURN_START_MOVE_DISTANCE * direction,
		TWEEN_DURATION,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")

func move_to(target : Battler):
	tween.interpolate_property(
		self,
		'global_position',
		global_position,
		target.target_global_position,
		TWEEN_DURATION,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")

func return_to_start():
	tween.interpolate_property(
		self,
		'position',
		position,
		position_start,
		TWEEN_DURATION,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")

func set_blink(value):
	blink = value
	if blink:
		anim.play("blink")
	else:
		anim.play("idle")

func stagger():
	battler_anim.stagger()
