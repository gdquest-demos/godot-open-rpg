extends Trigger

@export var activate_trigger: PackedScene


func _execute() -> void:
	assert(_gamepiece, "Trigger '%s' executed without valid gamepiece!" % name)
	
	music_player.tween_volume(-80.0, 1.5)
#	$AnimationPlayer.play("hide")
	await music_player.volume_changed
	
	$Timer.start()
	await $Timer.timeout
	
#	music_player.tween_volume(0.0, 1.5)
#	await music_player.volume_changed
	
	var new_trigger: = activate_trigger.instantiate()
	new_trigger.position = Vector2(168, 88)
	get_parent().add_child(new_trigger)
	
	$Timer.start()
	await $Timer.timeout
	
	$Timer.start()
	await $Timer.timeout
	
	new_trigger.is_active = true
	
#	$AnimationPlayer.play("show")
#	await $AnimationPlayer.animation_finished
