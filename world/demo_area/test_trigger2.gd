extends Trigger


func _execute() -> void:
	assert(_gamepiece, "Trigger '%s' executed without valid gamepiece!" % name)
	
	print("Activeate")
	
	music_player.tween_volume(-80, 1.5)
#	$AnimationPlayer.play("hide")
	await music_player.volume_changed
	
