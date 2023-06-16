extends Interaction

@export var moving_gamepiece: Gamepiece


func _execute() -> void:
	moving_gamepiece.travel_to_cell(Vector2i(1, 7))
	await moving_gamepiece.arrived
