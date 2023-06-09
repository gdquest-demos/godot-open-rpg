## A background object attached to a cinematic/'cutscene' event to transition to the cutscene.
## 
## The helper transitions the field game state to cinematic mode, at which point 
## [signal cinematic_mode_ready] is emitted. 
class_name CinematicEventHelper
extends Node

# Emitted when all gamepieces have finished travelling and cinematic mode can begin without
# interference.
signal cinematic_mode_ready


func _ready() -> void:
	FieldEvents.emit_signal.call_deferred("cinematic_mode_enabled")


func _process(_dt: float) -> void:
	for gamepiece in get_tree().get_nodes_in_group(Groups.GAMEPIECES):
		if (gamepiece as Gamepiece).is_travelling():
			return
	
	set_process(false)
	cinematic_mode_ready.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		FieldEvents.cinematic_mode_disabled.emit()
