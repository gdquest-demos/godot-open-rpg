@tool
## An [InteractionPopup] that follows a moving [GamepieceAnimation].
##
## This [code]Popup[/code] must be a child of a [GamepieceAnimation] to function.
##
## Note that other popup types will jump to the occupied cell of the ancestor [Gamepiece], whereas
## MovingInteractionPopups sync their position to that of the gamepiece's graphical representation.
extends InteractionPopup

@onready var _gp_animation: = get_parent() as GamepieceAnimation


func _ready() -> void:
	super._ready()
	
	# Do not follow anything in editor or if this object's parent is not of the correct type.
	if Engine.is_editor_hint() or not _gp_animation:
		set_process(false)


func _get_configuration_warnings() -> PackedStringArray:
	if not get_parent() is GamepieceAnimation:
		return ["This popup must be a child of a GamepieceAnimation node!"]
	return []


# Every process frame the popup sets its position to that of the graphical representation of the
# gamepiece, appearing to follow the gamepiece around the field while still playing nicely with the
# physics/interaction system.
func _process(_delta: float) -> void:
	position = _gp_animation.get_gfx_position()
