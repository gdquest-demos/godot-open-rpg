@icon("res://assets/editor/icons/Contact.svg")
class_name Trigger extends Area2D


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _on_area_entered(area: Area2D) -> void:
	print(area.owner.name, " entered")
	var gamepiece: = area.owner as Gamepiece
	if gamepiece:
		gamepiece.arriving.connect(_on_gamepiece_arrived.bind(gamepiece), CONNECT_ONE_SHOT)


func _on_area_exited(area: Area2D) -> void:
	print(area.owner.name, " left")


func _on_gamepiece_arrived(_distance: float, gamepiece: Gamepiece) -> void:
	print("Gampiece %s arrived!" % gamepiece.name)
