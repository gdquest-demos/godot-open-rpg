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


func _process(_delta: float) -> void:
	if _gamepiece.is_moving():
		return
	
	var input_direction: = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_direction:
		if not _gamepiece.is_moving():
			var source_cell: = GamepieceRegistry.get_cell(_gamepiece)
			var target_cell: = Vector2i.ZERO
			
			# Unless using 8-direction movement, one movement axis must be preferred. 
			#	Default to the x-axis.
			if not is_zero_approx(input_direction.x):
				input_direction = Vector2(input_direction.x, 0)
			else:
				input_direction = Vector2(0, input_direction.y)
			target_cell = Gameboard.pixel_to_cell(_gamepiece.position) + Vector2i(input_direction)
			
			# Try to get a path to destination (will fail if cell is occupied)
			var new_move_path: = Gameboard.pathfinder.get_path_to_cell(source_cell, target_cell)
			
			# Path is invalid. Bump animation?
			if new_move_path.size() <= 1:
				pass
			
			else:
				GamepieceRegistry.move_gamepiece(_gamepiece, target_cell)
				_gamepiece.move_to(Gameboard.cell_to_pixel(target_cell))
			print(new_move_path)
			#print(Gameboard.pathfinder.get_path_to_cell())
			# If path is valid, move.


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("select"):
		if move_path:
			move_path.clear()


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
