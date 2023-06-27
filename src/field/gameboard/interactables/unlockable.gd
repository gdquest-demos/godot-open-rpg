extends Interactable

@export var object_tiles: TileMap

var _remaining_triggers := 1000


func _ready() -> void:
	_remaining_triggers = await _setup_triggers()


func _on_trigger_interacted(trigger: Interactable) -> void:
	_remaining_triggers-= 1


func _on_interacted() -> void:
	if _remaining_triggers == 0:
		$Timer.start()
		await $Timer.timeout
		
		object_tiles.erase_cell(0, Vector2i(4, 17))
		
		$KeyHole/AnimationPlayer.play("fade")
		await $KeyHole/AnimationPlayer.animation_finished
		
		FieldEvents.terrain_changed.emit()
		queue_free()
	
	else:
		$Label2/AnimationPlayer.play("show_need_key")
