## A transition (usually between gameplay scenes) in which the screen is hidden behind an opaque
## color and then shown again.
##
## Screen transitions are often used in [Cutscenes] to cover up changes in the scenery or sudden
## changes to the loaded area. Many games begin with the screen covered and play some kind of
## animation before transitioning (see [method reveal]) to gameplay.
##
## [br][br]ScreenTransitions cover or reveal the screen uniformly as a fade animation.
class_name ScreenTransition extends CanvasLayer

## Emitted when the screen has finished the current animation, whether that is to [method cover] the
## screen or [method reveal] the screen.
signal finished

## The modulate color of the scene when it is to be invisible. Note that it is just
## [constant Color.WHITE] with a zero alpha channel.
const CLEAR: = Color(1, 1, 1, 0)

## The target modulate value of the scene when the transition covers the screen. Note that it is
## just [constant Color.WHITE].
## Consequently, the color of the screen transition may be set through the [member color] property.
const COVERED: = Color.WHITE

var _tween: Tween

@onready var _color_rect: = $ColorRect as ColorRect


func _ready() -> void:
	# The screen transitions need to run over the gameplay, which is instantiated below all
	# autoloads (including this class). Therefore, we want to move the ScreenTransition object to
	# the very bottom of the SceneTree's child list.
	# We cannot do so during ready, in which this node's parents are not yet ready. Therefore the
	# call to move_child must be deferred a frame.
	get_parent().move_child.call_deferred(self, get_parent().get_child_count()-1)
	
	# Allow the mouse through the transition GUI elements.
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# By default, do NOT have the ColorRect covering the screen.
	show()
	clear()


## Hide the ColorRect instantly, unless the duration argument is non-zero.
## This method is a coroutine that will finish once the screen has been cleared.
func clear(duration: = 0.0) -> void:
	if _tween:
		_tween.kill()
		_tween = null
		finished.emit()
	
	if is_equal_approx(duration, 0.0) or _color_rect.modulate.is_equal_approx(CLEAR):
		_color_rect.modulate = CLEAR
		call_deferred("emit_signal", "finished")
		
	else:
		_tween_transition(duration, CLEAR)
	
	await finished


## Cover the screen instantly, unless the duration argument is non-zero.
## This method is a coroutine that will finish once the screen has been covered.
func cover(duration: = 0.0) -> void:
	if _tween:
		if _tween.is_running():
			finished.emit()
		_tween.kill()
		_tween = null
		

	if is_equal_approx(duration, 0.0) or _color_rect.modulate.is_equal_approx(COVERED):
		_color_rect.modulate = COVERED
		call_deferred("emit_signal", "finished")
	
	else:
		_tween_transition(duration, COVERED)
	
	await finished


# Relegate the tween creation to a method so that derived classes can easily change transition type.
func _tween_transition(duration: float, target_color: Color) -> void:
	_tween = create_tween()
	_tween.tween_property(_color_rect, "modulate", target_color, duration)
	_tween.tween_callback(func(): emit_signal.call_deferred("finished"))
