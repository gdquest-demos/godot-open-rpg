@tool
## An [InteractionPopup] that follows a moving [Gamepiece].
##
## This [code]Popup[/code] must be a child of a [Gamepiece] to function.
##
## Note that other popup types will jump to the occupied cell of the ancestor [Gamepiece], whereas
## MovingInteractionPopups sync their position to that of the gamepiece's graphical representation.
extends InteractionPopup

@onready var _gp: = get_parent() as Gamepiece


func _ready() -> void:
	super._ready()
	
	# Do not follow anything in editor or if this object's parent is not of the correct type.
	if Engine.is_editor_hint() or not _gp:
		set_process(false)


func _get_configuration_warnings() -> PackedStringArray:
	if not _gp:
		return ["This popup must be a child of a Gamepiece node!"]
	return []


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		_gp = get_parent() as Gamepiece
		update_configuration_warnings()


# Every process frame the popup sets its position to that of the graphical representation of the
# gamepiece, appearing to follow the gamepiece around the field while still playing nicely with the
# physics/interaction system.
func _process(_delta: float) -> void:
	position = _gp.animation_transform.position
