extends CanvasLayer

@onready var _anim: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	await get_tree().process_frame
	await Transition.clear(0.5)
	
	_anim.play("fade_in")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		get_tree().quit()
		
	elif Input.is_anything_pressed():
		print("End it")
