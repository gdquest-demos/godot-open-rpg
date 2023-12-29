extends Node2D

@onready var _anim: AnimationPlayer = $AnimationPlayer


func _on_pickup_triggered(_gamepiece: Gamepiece) -> void:
	_anim.play("obtain")
	Inventory.restore().add(Inventory.ItemTypes.KEY, 1)
