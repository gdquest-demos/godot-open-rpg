@tool
## Applied to any gamepiece to allow player control.
##
## The controller responds to player input to handle movement and interaction.
class_name PlayerController extends GamepieceController

const GROUP: = "_PLAYER_CONTROLLER_GROUP"

# Keep track of a targeted interaction. Used to face & interact with the object at a path's end.
# It is reset on cancelling the move path or continuing movement via arrows/gamepad directions.
var _target_interaction: Interaction = null

# Keep track of any Triggers that the player has stepped on.
var _active_trigger: Trigger = null

# Also keep track of the most recently pressed move key (e.g. WASD keys). This makes keyboard input
# feel more intuitive, since the gamepiece will move towards the most recently pressed key rather
# than prefering an arbitrary axis.
var _last_input_direction: = Vector2.ZERO

# The "interaction searcher" area basically activates any Interactions, which means that they'll
# respond to key/button input.
@onready var _interaction_searcher: = $InteractionSearcher as Area2D
@onready var _interaction_shape: = $InteractionSearcher/CollisionShape2D as CollisionShape2D

# The player collision area activates Triggers whenever the player moves onto their collision
# shape.
@onready var _player_collision: = $PlayerCollision as Area2D


func _ready() -> void:
	super._ready()
	
	if not Engine.is_editor_hint():
		add_to_group(GROUP)
		
		# Refer the various player collision shapes to their gamepiece (parent of the controller).
		# This will allow other objects/systems to quickly find which gamepiece they are working on
		# via the collision "owners".
		_interaction_searcher.owner = _gamepiece
		_player_collision.owner = _gamepiece
		
		# Update the position of the player's collision shape to match the cell that it is currently
		# moving towards.
		waypoint_changed.connect(
			func _on_waypoint_changed(new_waypoint: Vector2i):
				if new_waypoint == Gameboard.INVALID_CELL:
					_player_collision.position = Vector2.ZERO
				else:
					_player_collision.position = Gameboard.cell_to_pixel(new_waypoint) \
						- _gamepiece.position
		)
		
		# The player collision picks up any triggers that it moves over. Keep track of them until
		# player movement to the current cells has completed.
		_player_collision.area_entered.connect(
			func _on_collision_triggered(area: Area2D):
				if area.owner is Trigger:
					_active_trigger = area.owner
		)
		
		_gamepiece.direction_changed.connect(
			func _on_gamepiece_direction_changed(new_direction: Directions.Points):
				var offset: Vector2 = Directions.MAPPINGS[new_direction] * 16
				_interaction_searcher.position = offset
		)
		
		FieldEvents.cell_selected.connect(_on_cell_selected)
		FieldEvents.interaction_selected.connect(_on_interaction_selected)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("select"):
		stop_moving()
	
	elif event is InputEventKey:
		if event.is_action_pressed("ui_up"):
			_last_input_direction = Vector2.UP
			if _gamepiece.is_moving():	stop_moving()
			else:	move_to_pressed_key(Vector2.UP)
			
		elif event.is_action_pressed("ui_down"):
			_last_input_direction = Vector2.DOWN
			if _gamepiece.is_moving():	stop_moving()
			else:	move_to_pressed_key(Vector2.DOWN)
			
		elif event.is_action_pressed("ui_left"):
			_last_input_direction = Vector2.LEFT
			if _gamepiece.is_moving():	stop_moving()
			else:	move_to_pressed_key(Vector2.LEFT)
			
		elif event.is_action_pressed("ui_right"):
			_last_input_direction = Vector2.RIGHT
			if _gamepiece.is_moving():	stop_moving()
			else:	move_to_pressed_key(Vector2.RIGHT)


func move_along_path(value: Array[Vector2i]) -> void:
	super.move_along_path(value.duplicate())
	
	_interaction_shape.disabled = true
	Player.player_path_set.emit(_gamepiece, value.back())


func move_to_pressed_key(input_direction: Vector2) -> void:
	if is_active:
		var source_cell: = GamepieceRegistry.get_cell(_gamepiece)
		var target_cell: = Vector2i.ZERO
		
		# Unless using 8-direction movement, one movement axis must be preferred. 
		#	Default to the x-axis.
		target_cell = source_cell + Vector2i(input_direction)
		
		# Try to get a path to destination (will fail if cell is occupied)
		var new_move_path: = Gameboard.pathfinder.get_path_to_cell(source_cell, target_cell)
		
		# Path is invalid. Bump animation?
		if new_move_path.size() < 1:
			_gamepiece.direction = Directions.angle_to_direction(input_direction.angle())
		
		else:
			move_path = new_move_path.duplicate()


func stop_moving() -> void:
	move_path.clear()
	_target_interaction = null


# The player has clicked on an empty gameboard cell. We'll try to move _gamepiece to the cell.
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
		var new_path = Gameboard.pathfinder.get_path_to_cell(source_cell, cell)
		if not new_path.is_empty():
			move_path = new_path.duplicate()


# The player has clicked on something interactable. We'll try to move next to the interaction and
# then run the interaction.
func _on_interaction_selected(interaction: Interaction) -> void:
	if is_active and not _gamepiece.is_moving():
		var source_cell: = Gameboard.pixel_to_cell(_gamepiece.position)
		var target_cell: = Gameboard.pixel_to_cell(interaction.position)
		
		if target_cell == source_cell:
			return
		
		# First of all, check to see if the target is adjacent to the source.
		if target_cell in Gameboard.get_adjacent_cells(source_cell):
			_gamepiece.direction \
				= Directions.vector_to_direction(interaction.position - _gamepiece.position)
			interaction.run()
		
		else:
			# Only cache the interaction and move towards it if there is a valid move path.
			var new_path = Gameboard.pathfinder.get_path_cells_to_adjacent_cell(source_cell, 
				target_cell)
			if not new_path.is_empty():
				_target_interaction = interaction
				
				move_path = new_path.duplicate()
	
	# If the player is already moving, cancel that movement.
	else:
		stop_moving()


func _on_gamepiece_arriving(excess_distance: float) -> void:
	# If the gamepiece moved onto a trigger, stop the gamepiece in its tracks.
	if _active_trigger:
		stop_moving()
	
	# Otherwise, carry on with movement.
	else:
		super._on_gamepiece_arriving(excess_distance)
		
		# It may be that the player is holding the keys down. In that case, continue moving the
		# gamepiece towards the pressed direction.
		var input_direction: = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if not input_direction.is_equal_approx(Vector2.ZERO):
			move_to_pressed_key(_last_input_direction)


func _on_gamepiece_arrived() -> void:
	super._on_gamepiece_arrived()
	
	_player_collision.position = Vector2.ZERO
	_interaction_shape.disabled = false
	
	# If there's a trigger at this cell, do nothing but reset the trigger reference.
	if _active_trigger:
		_active_trigger = null
	
	# Otherwise, if there's an interaction queued, run the interaction.
	elif _target_interaction:
		# Face the selected interaction...
		var direction_to_target: = _target_interaction.position - _gamepiece.position
		_gamepiece.direction = Directions.vector_to_direction(direction_to_target)
		
		# ...and then execute the interaction.
		_target_interaction.run()
		_target_interaction = null
	
	# No target, but check to see if the player is holding a key down and face in the direction of
	# the last pressed key.
	else:
		var input_direction: = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if not input_direction.is_equal_approx(Vector2.ZERO):
			_gamepiece.direction = Directions.vector_to_direction(_last_input_direction)
