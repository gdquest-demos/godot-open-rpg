@tool

class_name AreaTransition extends Trigger

@export var arrival_coordinates: Vector2:
	set(value):
		arrival_coordinates = value
		
		if Engine.is_editor_hint():
			if not is_inside_tree():
				await ready
			
			var target = $Destination as Sprite2D
			target.position = arrival_coordinates - position + target.texture.get_size()/2


func _ready() -> void:
	super._ready()
	
	if not Engine.is_editor_hint():
		$Destination.queue_free()


#func _execute() -> void:
	#print("Executing!")


func _on_area_entered(area: Area2D) -> void:
	
	$CanvasLayer/ScreenTransition.cover(0.25)
	await $CanvasLayer/ScreenTransition.finished
	
	await get_tree().process_frame
	_is_cutscene_in_progress = true
	
	var gamepiece: = area.owner as Gamepiece
	if gamepiece:
		gamepiece.cell = gamepiece.gameboard.pixel_to_cell(arrival_coordinates)
		gamepiece._on_travel_finished()
		gamepiece.get_parent().get_parent().get_parent().place_camera_at_focused_game_piece()
	
	await  get_tree().create_timer(0.20).timeout
	$CanvasLayer/ScreenTransition.reveal(0.10)
	await $CanvasLayer/ScreenTransition.finished
	_is_cutscene_in_progress = false
