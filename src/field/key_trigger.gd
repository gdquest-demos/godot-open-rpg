extends Trigger

@export var _anim: AnimationPlayer


func _ready() -> void:
	super._ready()
	assert(_anim, "%s error: animation player reference is not set!" % name)


func add_key() -> void:
	Dialogic.VAR.set_variable("NumKeys", Dialogic.VAR.NumKeys+1)


func _on_gamepiece_arrived(_distance: float, _gamepiece: Gamepiece) -> void:
	_anim.play("obtain")
