@tool
## Applied to any gamepiece to allow player control.
##
## The controller responds to player input to handle movement and interaction.
extends GamepieceController

const GROUP: = "_PLAYER_CONTROLLER_GROUP"

# Keep track of a targeted interaction. Used to face & interact with the object at a path's end.
# It is reset on cancelling the move path or continuing movement via arrows/gamepad directions.
var _target: Interaction = null


func _ready() -> void:
	super._ready()
	
	if not Engine.is_editor_hint():
		add_to_group(GROUP)
	
		FieldEvents.cell_selected.connect(_on_cell_selected)


func _on_cell_selected(cell: Vector2i) -> void:
	if is_active and not _gamepiece.is_moving():
		var source_cell: = Gameboard.pixel_to_cell(_gamepiece.position)
		
		# Don't move to the cell the focus is standing on.
		if cell == source_cell:
			return
		
		# Take a look at what's underneath the cursor. If there's an interaction, move towards it
		# and try to interact with it.
		
		# Otherwise it's just the empty gameboard, so we'll try to move the player towards the
		# selected cell.
		move_path = Gameboard.pathfinder.get_path_to_cell(source_cell, cell)
		if not move_path.is_empty():
			FieldEvents.player_path_set.emit(_gamepiece, move_path.back())
		
		# If there is an interaction underneath the cursor the player's gamepiece should flag the
		# target and move to an adjacent cell.
		#if not collisions.is_empty():
			#for collision: Dictionary in collisions:
				#if collision.collider.owner is Interaction:
					#_target = collision.collider.owner
					#break
		
		# The following method will move to an empty cell OR adjacent to a blocked cell that has
		# an interaction located on it.
		
		
		#travel_to_cell(cell, _target != null)
		#if not _waypoints.is_empty():
			#FieldEvents.player_path_set.emit(_gamepiece, _waypoints.back())
		#
		## There is no path but there is a target, which means that the player is standing right next
		## to the target interaction.
		#elif _target:
			#_on_gamepiece_arrived()
