extends Trigger

@export var _anim: AnimationPlayer


func _ready() -> void:
	super._ready()
	assert(_anim, "%s error: animation player reference is not set!" % name)


func _on_area_entered(area: Area2D) -> void:
	super._on_area_entered(area)
	_anim.play("open")
