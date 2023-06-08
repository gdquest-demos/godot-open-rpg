extends Trigger


func _execute() -> void:
	assert(_gamepiece, "Trigger '%s' executed without valid gamepiece!" % name)
	
	music_player.tween_volume(-20.0, 3.5)
	$AnimationPlayer.play("hide")
	await music_player.volume_changed
	
	$Timer.start()
	await $Timer.timeout
	
	music_player.tween_volume(0.0, 1.5)
	await music_player.volume_changed
	
	$AnimationPlayer.play("show")
	await $AnimationPlayer.animation_finished
