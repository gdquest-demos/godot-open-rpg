## ISpecialized [Event]s that are intended to be children of [Gamepiece]s (though not required). 
##
## Interactions are triggered exclusively by the player via the interaction input action or by
## clicking on a cell with an interaction object (for example an NPC to talk to).
## [br][br]Interactions also change the cursor via [member cursor_image] based on desired
## functionality. See [enum FieldCursor.Images] for available cursor images.
class_name Interaction
extends Event

signal highlighted(image: int)
signal unhighlighted

@export var cursor_image: = FieldCursor.Images


func _ready() -> void:
	super._ready()


func _on_mouse_entered() -> void:
	highlighted.emit(cursor_image)


func _on_mouse_exited() -> void:
	unhighlighted.emit()
