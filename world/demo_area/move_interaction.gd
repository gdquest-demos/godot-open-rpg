extends Interactable

@export var moving_gamepiece: Gamepiece


func _on_interacted() -> void:
	moving_gamepiece.travel_to_cell(Vector2i(1, 7))
	await moving_gamepiece.arrived
