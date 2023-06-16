extends Interaction

@export var object_tiles: TileMap

var has_key: = false


func _execute() -> void:
	if has_key:
		$Timer.start()
		await $Timer.timeout
		
		object_tiles.erase_cell(0, Vector2i(4, 17))
		
		$KeyHole/AnimationPlayer.play("fade")
		await $KeyHole/AnimationPlayer.animation_finished
		
		FieldEvents.terrain_changed.emit()
		queue_free()
	
	else:
		$Label2/AnimationPlayer.play("show_need_key")
