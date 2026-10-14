extends GameState

@onready var _anim: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		get_tree().quit()
	
	elif Input.is_anything_pressed():
		_transition_to_overworld()


func start() -> void:
	await Transition.clear(0.4)
	_anim.play("fade_in")
	await _anim.animation_finished
	set_process_unhandled_input(true)


func _transition_to_overworld() -> void:
	set_process_unhandled_input(false)
	_anim.play("fade_out")
	await _anim.animation_finished
	
	await Transition.cover(0.4)
	transition_executed.emit(Game.States.OVERWORLD)
