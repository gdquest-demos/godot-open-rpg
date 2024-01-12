## A transition (usually between gameplay scenes) in which the screen is hidden behind an opaque
## colour and then shown again.
##
## Screen transitions are often used in [Cutscenes] to cover up changes in the scenery or sudden
## changes to the loaded area. Many games begin with the screen covered and play some kind of
## animation before transitioning (see [method reveal]) to gameplay.
##
## [br][br]ScreenTransitions cover or reveal the screen uniformly as a fade animation.
class_name ScreenTransition extends ColorRect

## Emitted when the screen has finished the current animation, whether that is to [method cover] the
## screen or [method reveal] the screen.
signal finished

## The modulate colour of the scene when it is to be invisible. Note that it is just
## [constant Color.WHITE] with a zero alpha channel.
const CLEAR: = Color(1, 1, 1, 0)

## The target modulate value of the scene when the transition covers the screen. Note that it is
## just [constant Color.WHITE].
## Consequently, the colour of the screen transition may be set through the [member color] property.
const COVERED: = Color.WHITE

var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# By default, do NOT have the ColorRect covering the screen.
	show()
	reveal()


## Hide the ColorRect instantly, unless the duration argument is non-zero.
func reveal(duration: = 0.0) -> void:
	if _tween:
		_tween.kill()
		_tween = null
		finished.emit()
	
	if is_equal_approx(duration, 0.0):
		modulate = CLEAR
		call_deferred("emit_signal", "finished")
		
	else:
		_tween_transition(duration, CLEAR)


## Cover the screen instantly, unless the duration argument is non-zero.
func cover(duration: = 0.0) -> void:
	if _tween:
		_tween.kill()
		_tween = null
		finished.emit()

	if is_equal_approx(duration, 0.0):
		modulate = COVERED
		call_deferred("emit_signal", "finished")
	
	else:
		_tween_transition(duration, COVERED)


# Relegate the tween creation to a method so that derived classes can easily change transition type.
func _tween_transition(duration: float, target_colour: Color) -> void:
	_tween = create_tween()
	_tween.tween_property(self, "modulate", target_colour, duration)
	_tween.tween_callback(func(): finished.emit())
