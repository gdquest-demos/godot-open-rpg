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

@onready var _debug_boundaries: DebugGameboardBoundaries = $DebugBoundaries

func _ready() -> void:
	if not Engine.is_editor_hint():
		Camera.gameboard_properties = gameboard_properties
		Gameboard.properties = gameboard_properties
		
		# Gamepieces need to be registered according to which cells they currently occupy.
		# Gamepieces may not overlap, and only the first gamepiece registered to a given cell will
		# be kept.
		for gp: Gamepiece in find_children("*", "Gamepiece"):
			var cell: = Gameboard.pixel_to_cell(gp.position)
			gp.position = Gameboard.cell_to_pixel(cell)
			
			if GamepieceRegistry.register(gp, cell) == false:
				gp.queue_free()
		
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		print(Gameboard.pathfinder)
