extends Interactable


func _on_gamepiece_entered() -> void:
	$AnimationPlayer.play("fade_out")
