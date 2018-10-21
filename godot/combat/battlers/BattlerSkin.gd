extends Position2D

export var TURN_START_MOVE_DISTANCE : float = 40.0
export var TWEEN_DURATION : float = 0.3
onready var tween = $Tween

onready var position_start : Vector2 = position

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
