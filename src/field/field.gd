extends Node

## The physics layers which will be used to search for gamepiece obejcts.
## Please see the project properties for the specific physics layers. [b]All[/b] collision shapes
## matching the mask will be checked regardless of position in the scene tree.
@export_flags_2d_physics var gamepiece_mask: = 0

## The physics layers which will be used to search for terrain obejcts.
@export_flags_2d_physics var terrain_mask: = 0

@onready var player: = $PlayerParty as FieldPlayer


func initialize() -> void:
	# Wait a single frame for the physics server to update.
	await get_tree().process_frame
	
	player.initialize(gamepiece_mask, terrain_mask)
	
	player.set_focus($Gameboard/Objects/Gamepieces/Player)
	player.place_camera_at_focus()
	player.is_active = true
