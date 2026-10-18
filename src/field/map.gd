@tool
extends Node2D

## The map defines the properties of the playable grid, which will be applied on _ready to the
## [Gameboard]. These properties usually correspond to one or multiple tilesets.
@export var gameboard_properties: GameboardProperties:
	set(value):
		gameboard_properties = value
		
		if not is_inside_tree():
			await ready
		
		_debug_boundaries.gameboard_properties = gameboard_properties 

@onready var _debug_boundaries: DebugGameboardBoundaries = $Overlay/DebugBoundaries

func _ready() -> void:
	if not Engine.is_editor_hint():
		Gameboard.properties = gameboard_properties
