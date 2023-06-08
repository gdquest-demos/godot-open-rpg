
## Disable all input methods into the field state, including controllers (both player and AI), the
## cursor, and other input events.
## Additionally, the function will begin a process that will wait for all currently moving
## gamepieces to finish their movement at which point [signal cinematic_mode_started] will be
## emitted.
class_name CinematicModeListener
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
