extends CanvasLayer

@onready var _anim: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	await get_tree().process_frame
	await Transition.clear(0.5)
	
	_anim.play("default")
