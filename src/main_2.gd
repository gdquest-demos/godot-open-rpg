extends Node2D

@export var collision_tilemaps: Array[TileMapLayer] = []

var pathfinder: Pathfinder


func _ready() -> void:
	#Gameboard.properties = $Map/DebugMoveGrid/DebugBoundaries.gameboard_properties
	assert(Gameboard.properties != null, "The Gameboard autoload must have a GameboardProperties" +
		"resource set before its _ready function is called!")
	
	pathfinder = Pathfinder.new()
	
	for gp: Gamepiece in $Gamepieces.get_children():
		var cell: = Gameboard.pixel_to_cell(gp.position)
		gp.position = Gameboard.cell_to_pixel(cell)
		
		if GamepieceRegistry.register(gp, cell) == false:
			gp.queue_free()
	
	#print("Create tilemap here")
	
	for tilemap in collision_tilemaps:
		tilemap.add_to_group(Gameboard.COLLISION_TILEMAPLAYER_GROUP)
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	#print(Gameboard.pathfinder)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		$Map/TileMapLayer2.set_cell(Vector2i(4,3))
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		print(Gameboard.pathfinder)
