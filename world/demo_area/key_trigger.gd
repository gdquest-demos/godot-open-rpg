extends Trigger

@export var key_interaction_path: NodePath


func _execute() -> void:
	$Sprite2D/AnimationPlayer.play("fade")
	
	var key_interaction = get_node(key_interaction_path)
	key_interaction.has_key = true
