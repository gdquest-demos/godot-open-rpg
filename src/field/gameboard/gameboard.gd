## The gameboard is a high-level object coordinating most game objects.
class_name Gameboard
extends Node2D

@export var grid: Grid

var gamepieces: GamepieceDirectory = null
var pathfinder: Pathfinder = null

@onready var cursor: = $Objects/Cursor as FieldCursor
@onready var _debug_map_boundaries: = $DebugMapBoundaries
@onready var _obstacles: = $Objects as ObstacleMap
@onready var _terrain: = $Terrain as TerrainMap


func _ready() -> void:
	if not Engine.is_editor_hint():
		_debug_map_boundaries.queue_free()
		_debug_map_boundaries = null
	
	# Setup the various systems/databases that will determine how the world works.
	assert(grid, "The gameboard does not have a vaild Grid object!")
	gamepieces = GamepieceDirectory.new(_get_gamepiece_by_name)
	_build_pathfinder()
	
	cursor.initialize(grid, pathfinder)
	
	var highlight_strategy: = CursorHighlightDefault.new()
	cursor.set_highlight_strategy(highlight_strategy)
	
	for child in $Objects/Gamepieces.get_children():
		if child is Gamepiece:
			child.initialize(grid)
	
	$DebugWalkableCells.initialize(grid, gamepieces, _terrain.get_walkable_cells(grid.boundaries), 
		_obstacles.get_blocked_cells(grid.boundaries))


func _build_pathfinder() -> void:
	# We're going to build a pathfinder from the unoccupied cells used by the various tilemaps.
	var walkable_cells: Array[Vector2i] = []
	
	# The Objects tilemap stores obstacles that the player may not move through.
	var blocked_cells: = _obstacles.get_blocked_cells(grid.boundaries)
	
	# The player should be able to walk on all obstacle-less cells painted onto the Terrain tilemap. 
	#	This tilemap may have several layers, so each must be accounted for.
	for cell in _terrain.get_walkable_cells(grid.boundaries):
		if not cell in blocked_cells and not cell in walkable_cells:
			walkable_cells.append(cell)
	
	pathfinder = Pathfinder.new(walkable_cells, grid)


# Defer the ability to lookup gamepieces by name to the directory. Since the directory is a
#	RefCounted object, we need to pass in a lookup callable that takes a uid string as parameter.
func _get_gamepiece_by_name(gp_name: String) -> Gamepiece:
	if $Objects/Gamepieces.has_node(gp_name):
		return $Objects/Gamepieces.get_node(gp_name) as Gamepiece
	return null
