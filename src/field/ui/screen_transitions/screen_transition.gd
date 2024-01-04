class_name ScreenTransition extends ColorRect

signal finished

const CLEAR: = Color(1, 1, 1, 0)
const COVERED: = Color.WHITE

var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	show()
	reveal()


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
