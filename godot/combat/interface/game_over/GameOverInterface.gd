extends CanvasLayer
class_name GameOverInterface

onready var panel : = $Panel as Panel

func display() -> void:
	panel.show()

func _on_Exit_pressed() -> void:
	get_tree().quit()
