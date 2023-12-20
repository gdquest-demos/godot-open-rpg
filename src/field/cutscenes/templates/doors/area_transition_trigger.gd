extends Trigger


func _on_gamepiece_arrived(_distance: float, gamepiece: Gamepiece) -> void:
	super._on_gamepiece_arrived(_distance, gamepiece)
	print("Transition to new area!")
