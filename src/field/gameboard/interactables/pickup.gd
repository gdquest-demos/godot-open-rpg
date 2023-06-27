extends Interactable


func _on_gamepiece_entered() -> void:
	$Sprite2D/AnimationPlayer.play("fade")
	interacted.emit()
