extends GameState

@onready var _anim: AnimationPlayer = $AnimationPlayer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		get_tree().quit()
		
	elif Input.is_anything_pressed():
		print("End it")


func start() -> void:
	await Transition.clear(0.4)
	_anim.play("fade_in")
