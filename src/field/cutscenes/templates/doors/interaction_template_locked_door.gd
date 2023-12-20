extends Interaction

@export var _anim: AnimationPlayer


func _ready():
	assert(_anim, "%s error: animation player reference is not set!" % name)
	super._ready()
	
	Dialogic.VAR.variable_changed.connect(_on_var_changed)


func _execute() -> void:
	print("Door keys:" ,Dialogic.VAR.NumKeys)
#	Dialogic.VAR.NumKeys = 3
	if not _anim.is_playing():
		if Dialogic.VAR.NumKeys > 0:
			Dialogic.VAR.set_variable("NumKeys", Dialogic.VAR.NumKeys-1)
			_anim.play("open")
		
		else:
			_anim.play("locked")
		
		# We rely on the physics engine for movement, so the physics state of the open door (whose
		# collision shape we just turned on/off with the animation player) must update at a physics
		# step before pathfinders can adjust to the door's new state.
		# SceneTree.physics_frame is emitted BEFORE the physics step, so we want to wait until a
		# second signal is emitted before updating pathfinding.
		await get_tree().physics_frame
		await get_tree().physics_frame
		FieldEvents.terrain_changed.emit()


func _on_var_changed(_data: Dictionary) -> void:
	pass
