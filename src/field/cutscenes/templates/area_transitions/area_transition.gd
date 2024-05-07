@tool

class_name AreaTransition extends Trigger

@export var arrival_coordinates: Vector2:
	set(value):
		arrival_coordinates = value
		
		if Engine.is_editor_hint():
			if not is_inside_tree():
				await ready
			
			var target = $Destination as Sprite2D
			target.position = arrival_coordinates - position


#TODO: this will become a property of a given area once proper gameplay areas have been implemented.
@export var new_music: AudioStream

# The blackout timer is used to wait between fade-out and fade-in. No delay looks odd.
@onready var _blackout_timer: = $BlackoutTimer as Timer


func _ready() -> void:
	super._ready()
	
	if not Engine.is_editor_hint():
		$Destination.queue_free()


# Area transitions are given several opportunities to "do something" at various stages, such as
# before the camera fades away, after it has faded, and immediately after it re-appears in the new
# area. 
# This could include all manner of shenanigans, such as dropping in the on the Big Baddie's 
# monologue, showing the player's stalker after the player has left the scene, or playing out an
# event that the player then walks into the middle of.
func _on_area_entered(area: Area2D) -> void:
	# Pausing the field immediately will deactivate physics objects, which are in the middle of
	# processing (hence _on_area_entered). We need to wait a frame before pausing anything.
	await get_tree().process_frame
	
	# Pause the field gamestate to prevent the player from wandering off mid-transition.
	_is_cutscene_in_progress = true
	
	# Cover the screen to hide the area transition.
	Transition.cover(0.25)
	await Transition.finished
	
	# Move the gamepiece to it's new position and update the camera immediately.
	var gamepiece: = area.owner as Gamepiece
	if gamepiece:
		gamepiece.cell = gamepiece.gameboard.pixel_to_cell(arrival_coordinates)
		gamepiece.reset_travel()
		
		Camera.reset_position()
	
	# Let the screen rest in darkness for a little while. Revealing the screen immediately with no
	# delay looks 'off'.
	_blackout_timer.start()
	await _blackout_timer.timeout
	
	# All kinds of shenanigans could happen once the screen blacks out. It may be asynchronous, so
	# give the opportunity for the designer to run a lengthy event.
	@warning_ignore("redundant_await")
	await _on_blackout()
	
	# Reveal the screen and unpause the field gamestate.
	Transition.clear(0.10)
	await Transition.finished
	
	# Finally, unpause the field gameplay, allowing the player to move again.
	_is_cutscene_in_progress = false


func _on_blackout() -> void:
	Music.play(new_music, 0.0, 0.15)
