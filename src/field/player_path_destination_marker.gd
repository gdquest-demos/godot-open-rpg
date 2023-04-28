extends Sprite2D

@export var grid: Grid


func _ready() -> void:
	FieldEvents.player_path_set.connect(_on_player_path_set)


func _on_gamepiece_arrived(gamepiece: Gamepiece) -> void:
	hide()
	
	gamepiece.arrived.disconnect(_on_gamepiece_arrived)


func _on_player_path_set(gamepiece: Gamepiece, destination_cell: Vector2i) -> void:
	gamepiece.arrived.connect(_on_gamepiece_arrived.bind(gamepiece))
	
	position = grid.cell_to_pixel(destination_cell)
	show()
