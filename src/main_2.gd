extends Node2D

@export var collision_tilemaps: Array[TileMapLayer] = []


func _ready() -> void:
	for gp: Gamepiece in $Gamepieces.get_children():
		var cell: = Gameboard.pixel_to_cell(gp.position)
		gp.position = Gameboard.cell_to_pixel(cell)
		
		if GamepieceRegistry.register(gp, cell) == false:
			gp.queue_free()
	
	for tilemap in collision_tilemaps:
		tilemap.add_to_group(Gameboard.COLLISION_TILEMAPLAYER_GROUP)
