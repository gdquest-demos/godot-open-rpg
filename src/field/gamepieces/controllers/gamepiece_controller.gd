@tool
## Base controller responsible for the pathfinding state and movement of a gamepiece.
##
## A controller is responsible for all gamepiece behaviour, especially movement. The base controller
## provides several utility methods that query the [Gameboard]/[Gamepiece] state. 
##
## [br][br]Please note that the GamepieceController class doesn't [i]do[/i] anything. Specific 
## controllers will usually be subclassed from this base class. See [PlayerController] for a
## detailed example.
##
## [br][br]Requires a gamepiece as parent. The controller is derived from Node2D to account for
## [member global_scale] when searching for paths/objects.
## [br][br][b]Note:[/b] The controller is an optional component. Only gamepieces requiring player 
## input or AI will be controlled.
class_name GamepieceController
extends Node2D

# Colliding objects that have the following property set to true will block movement.
const IS_BLOCKING_METHOD: = "blocks_movement"

## Colliders matching the following mask will be used to determine which cells are walkable. Cells
## containing any terrain collider will not be included for pathfinding.
@export_flags_2d_physics var terrain_mask: = 0x1

## Colliders matching the following mask will be used to determine which cells are blocked by other
## gamepieces.
@export_flags_2d_physics var gamepiece_mask: = 0

## A pathfinder will be built from and respond to the physics state. This will be used to determine
## movement for the parent [Gamepiece].
var pathfinder: Pathfinder

# Keep track of cells that need an update and do so as a batch before the next path search.
var _cells_to_update: PackedVector2Array = []

var _focus: Gamepiece
var _gameboard: Gameboard

var _gamepiece_searcher: CollisionFinder
var _terrain_searcher: CollisionFinder


func _ready() -> void:
	if not Engine.is_editor_hint():
		_focus = get_parent() as Gamepiece
		assert(_focus, "The GamepieceController must have a Gamepiece as a parent. "
			+ "%s is not a gamepiece!" % get_parent().name)
		
		_gameboard = _focus.gameboard
		assert(_gameboard, "%s error: invalid Gameboard object!" % name)
		
		# The controller will be notified of any changes in the gameboard and respond accordingly.
		FieldEvents.gamepiece_cell_changed.connect(_on_gamepiece_cell_changed)
		FieldEvents.terrain_changed.connect(_on_terrain_passability_changed)
		
		# Create the objects that will be used to query the state of the gamepieces and terrain.
		var min_cell_axis: = minf(_gameboard.cell_size.x-1, _gameboard.cell_size.y-1) / 2.0
		_gamepiece_searcher = CollisionFinder.new(get_world_2d().direct_space_state, min_cell_axis,
			gamepiece_mask)
		_terrain_searcher = CollisionFinder.new(get_world_2d().direct_space_state, min_cell_axis,
			terrain_mask)
		
		await get_tree().process_frame
		_rebuild_pathfinder()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not get_parent() is Gamepiece:
		warnings.append("Expects a Gamepiece as parent to correctly function. "
			+ "Please only use GamepieceController as a child of a Gamepiece for correct animation.")
	
	return warnings


## Returns true if a given cell is occupied by something that has a collider matching 
## [member gamepiece_mask].
func is_cell_blocked(cell: Vector2i) -> bool:
	var search_coordinates: = Vector2(_gameboard.cell_to_pixel(cell)) * global_scale
	var collisions = _gamepiece_searcher.search(search_coordinates)
	
	# Take advantage of duck typing: any colliding object could block movement. Look at the owner
	# of the collision shape for a blocking flag.
	# Please see BLOCKING_PROPERTY for more information.
	for collision in collisions:
		if collision.collider.owner.has_method(IS_BLOCKING_METHOD):
			if collision.collider.owner.call(IS_BLOCKING_METHOD):
				return true
	
	# There is one last check to make. It is possible that a gamepiece has decided to move to cell 
	# THIS frame. It's collision shape will not move until next frame, so the events manager may
	# have flagged this cell as 'targeted this frame'.
	return FieldEvents.did_gp_move_to_cell_this_frame(cell)


## Find all collision matching [member gamepiece_mask] at a given cell.
func get_collisions(cell: Vector2i) -> Array:
	var search_coordinates: = Vector2(_gameboard.cell_to_pixel(cell)) * global_scale
	return _gamepiece_searcher.search(search_coordinates)


# Completely rebuild the pathfinder, searching for all empty terrain within the gameboard 
# boundaries.
# Empty terrain is considered a cell that is NOT occupied by a collider with a terrain_mask.
func _rebuild_pathfinder() -> void:
	var pathable_cells: Array[Vector2i] = []
	
	# Loop through ALL cells within the board boundaries. The only cells that will not be considered
	# walkable are those that contain a collision shape matching the terrain layer mask.
	for x in range(_gameboard.boundaries.position.x, _gameboard.boundaries.end.x):
		for y in range(_gameboard.boundaries.position.y, _gameboard.boundaries.end.y):
			var cell: = Vector2i(x, y)
			
			# To find collision shapes we'll query a PhysicsDirectSpaceState2D (usually that of the
			# current viewport's World2D). If there is a collision shape matching terrainn_mask
			# then we'll know to discard the cell. Otherwise it may be considered walkable.
			var search_coordinates: = Vector2(_gameboard.cell_to_pixel(cell)) * global_scale
			var collisions: = _terrain_searcher.search(search_coordinates)
			if collisions.is_empty():
				pathable_cells.append(cell)
	
	pathfinder = Pathfinder.new(pathable_cells, _gameboard)
	_find_all_blocked_cells()


# The following method searches ALL cells contained in the pathfinder for objects that might block
# gamepiece movement. 
# 
# This method may be overwritten depending on the movement behaviour of a controller's focus. For
# instance, a teleporting or flying focus will not be blocked by grounded gamepieces.
func _find_all_blocked_cells() -> void:
	var blocked_cells: Array[Vector2i] = []
	
	for cell in pathfinder.get_cells():
		if is_cell_blocked(cell):
			blocked_cells.append(cell)
	
	pathfinder.set_blocked_cells(blocked_cells)


# Go through all cells that have been flagged for updates and determine if they are indeed occupied.
# This should usually be called before searching for a move path.
func _update_changed_cells() -> void:
	# Duplicate entries may be included in _cells_to_update. Filter them by converting the array to
	# dictionary keys (which are always unique).
	# This ensures that given coordinates are only queried once per update.
	var checked_coordinates: = {}
	
	for cell in _cells_to_update:
		if not cell in checked_coordinates:
			pathfinder.block_cell(cell, is_cell_blocked(cell))
			checked_coordinates[cell] = null
	
	_cells_to_update.clear()


# Whenever a gamepiece moves, flag its destination and origin as in need of an update.
func _on_gamepiece_cell_changed(gamepiece: Gamepiece, old_cell: Vector2) -> void:
	_cells_to_update.append(old_cell)
	_cells_to_update.append(gamepiece.cell)


# Various events may trigger a change in the terrain which, in turn, changes which cells are
# passable. The pathfinder will need to be rebuilt.
func _on_terrain_passability_changed() -> void:
	_rebuild_pathfinder()
