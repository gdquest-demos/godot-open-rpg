## The cursor of a [UIListMenu], indicating which option is currently in focus.
class_name UIMenuCursor extends Marker2D

## The time taken to move the cursor from one menu entry to the next.
const SLIDE_TIME: = 0.1

# The tween used to move the cursor between menu entries.
var _slide_tween: Tween = null

@onready var _anim: = $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	# The arrow needs to move indepedently from its parent.
	set_as_top_level(true)


## Smoothly move the cursor to an arbitrary position.
## Called by the menu to move the cursor from entry to entry.
func move_to(target: Vector2) -> void:
	if _slide_tween:
		_slide_tween.kill()
	_slide_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_slide_tween.tween_property(self, "position", target, SLIDE_TIME)


## Advance the arrows animation to a given point.
func advance_animation(seconds: float) -> void:
	_anim.seek(seconds, true)


## Get the current position of the bounce animation.
func get_animation_position() -> float:
	return _anim.get_current_animation_position()
