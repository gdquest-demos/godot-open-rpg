## An animated combat UI element emphasizing damage done (or healed) to a battler.
class_name UIDamageLabel extends Marker2D

## Determines how far the label will move upwards.
@export var move_distance: = 96.0

## Determines how long the label will be moving upwards.
@export var move_time: = 0.6

## Determines how long it will take for the label to fade to transparent. This occurs at the end of
## the upwards movement.
## <br><br><b>Note:</b> fade_time must be less than [member move_time].
@export var fade_time: = 0.2

## Label color when [member amount] is >= 0.
@export var color_damage := Color("#b0305c")

## Label outline color when [member amount] is >= 0.
@export var color_damage_outline := Color("#b0305c")

## Label color when [member amount] is < 0.
@export var color_heal := Color("#3ca370")

## Label outline color when [member amount] is < 0.
@export var color_heal_outline := Color("#3ca370")

## Consistent with [BattlerHit], damage values greater than 0 incur damage whereas those less than 0
## are for healing.
var amount := 0:
	set(value):
		amount = value
		
		if not is_inside_tree(): await ready
		_label.text = str(amount)
		
		if amount >= 0:
			_label.modulate = color_damage
			_label.add_theme_color_override("font_outline_colour", color_damage_outline)
		else:
			_label.modulate = color_heal
			_label.add_theme_color_override("font_outline_colour", color_heal_outline)

var _tween: Tween = null

@onready var _label: = $Label as Label


func _ready() -> void:
	assert(fade_time < move_time, "%s's fade_time must be less than its move_time!")


func setup(origin: Vector2, damage_amount: int) -> void:
	global_position = origin
	amount = damage_amount
	
	# Animate the label, moving it in an upwards direction.
	# We define a range of 60 degrees for the labels movement.
	var angle := randf_range(-PI / 6.0, PI / 6.0)
	var target := Vector2.UP.rotated(angle) * move_distance + _label.position
	
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(
		_label,
		"position",
		target,
		move_time
	)
	
	# Fade out the label at the end of it's movement upwards.
	_tween.parallel().tween_property(
		self, 
		"modulate", 
		Color.TRANSPARENT, 
		fade_time
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR).set_delay(move_time-fade_time)
	
	# Finally, after everything prior has finished, free the label.
	_tween.tween_callback(queue_free)
