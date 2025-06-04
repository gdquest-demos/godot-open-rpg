@tool
extends Node2D

@export var gameboard_properties: GameboardProperties:
	set(value):
		gameboard_properties = value
		
		if not is_inside_tree():
			await ready
		
		_debug_boundaries.gameboard_properties = gameboard_properties


@onready var _debug_boundaries: DebugGameboardBoundaries = $DebugBoundaries

func _ready() -> void:
	Gameboard.properties = gameboard_properties
