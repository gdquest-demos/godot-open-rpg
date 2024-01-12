## A cutscene stops field gameplay to run a scripted event.
##
## A cutscene may be thought of as the videogame equivalent of a short scene in a film. For example,
## dialogue may be displayed, the scene may switch to show key NPCs performing an event, or the
## inventory may be altered. Gameplay on the field is [b]stopped[/b] until the cutscene concludes,
## though this may span a combat scenario (e.g. epic bossfight).
##
##[br][br]
## Cutscenes may or may not have duration, and only one cutscene may be active at a time. Field
## gameplay is stopped for the entire duration of the active cutscene.
## Gameplay is stopped by emitting the global [signal FieldEvents.input_paused] signal.
## AI and player objects respond to this signal. For examples or responses to this signal, see
## [member GamepieceController.is_paused] or [method FieldCursor._on_input_paused].
##
##[br][br]
## Cutscenes are inherently custom and must be derived to do anything useful. They may be run via
## the [method run] method and derived cutscenes will override the [method _execute] method to
## provide custom functionality.
##
##[br][br]
## Cutscenes are easily extensible, taking advantage of Godot's scene architecture. A variety of
## cutscene templates are included out-of-the-box. See [Trigger] for a type of cutscene that is
## triggered by contact with a gamepeiece. See [Interaction] for cutscene's that are triggered by
## the player interaction with them via a keypress or touch. Several derived temlpates (for example,
## open-able doors) are included in res://field/cutscenes/templates.
@icon("res://assets/editor/icons/Cutscene.svg")
class_name Cutscene extends Node2D

# Indicates if a cutscene is currently running. [b]This member should not be set externally[/b].
static var _is_cutscene_in_progress: = false:
	set(value):
		if _is_cutscene_in_progress != value:
			_is_cutscene_in_progress = value
			
			FieldEvents.input_paused.emit(value)


## Returns true if a cutscene is currently running.
static func is_cutscene_in_progress() -> bool:
	return _is_cutscene_in_progress


## Execute the cutscene, if possible. Everything happening on the field gamestate will be
## paused and unpaused as the cutscene starts and finishes, respectively.
func run() -> void:
	_is_cutscene_in_progress = true
	
	# The _execute method may or may not be asynchronous, depending on the particular cutscene.
	@warning_ignore("redundant_await")
	await _execute()
	
	_is_cutscene_in_progress = false


## Play out the specific events of the cutscene.
## This method is intended to be overridden by derived cutscene types.
## [br][br]May or may not be asynchronous.
func _execute() -> void:
	pass
