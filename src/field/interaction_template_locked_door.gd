extends Interaction

@export var _anim: AnimationPlayer


func _ready():
	assert(_anim, "%s error: animation player reference is not set!" % name)
	super._ready()
	
	Dialogic.VAR.variable_changed.connect(_on_var_changed)


func interact() -> void:
	print(Dialogic.VAR.NumKeys)
	Dialogic.VAR.NumKeys = 3
	if not _anim.is_playing():
		if Dialogic.VAR.NumKeys > 0:
			Dialogic.VAR.set_variable("NumKeys", Dialogic.VAR.NumKeys-1)
			_anim.play("open")
		
		else:
			_anim.play("locked")


func _on_var_changed(_data: Dictionary) -> void:
	pass
