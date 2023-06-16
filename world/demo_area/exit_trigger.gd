extends Trigger


func _execute() -> void:
	$AnimationPlayer.play("fade_out")
