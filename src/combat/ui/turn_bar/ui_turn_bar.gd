## Displays the timeline representing the turn order of all battlers in the arena.
## Battler icons move along the timeline in real-time as their readiness updates.
class_name UITurnBar extends Control

const ICON_SCENE: = preload("ui_battler_icon.tscn")

@onready var _anim: = $AnimationPlayer as AnimationPlayer
@onready var _background: = $Background as TextureRect
@onready var _icons: = $Background/Icons as Control


## Fade in (from transparent) the turn bar and all of its UI elements.
func fade_in() -> void:
	_anim.play("fade_in")


## Initialize the turn bar, passing in all the battlers that we want to display.
func setup(battlers: Array[Battler]) -> void:
	for battler in battlers:
		# We first calculate the right icon background using the `Types` enum from `UIBattlerIcon`.
		# Below, I'm using the ternary operator. It picks the first value if the condition is `true`,
		# otherwise, it picks the second value.
		var battler_allegiance: = UIBattlerIcon.Types.PLAYER if battler.is_player \
			else UIBattlerIcon.Types.ENEMY
		
		# Connect a handful of signals to the icon so that it may respond to changes in the
		# Battler's readiness and fade out if the Battler falls in combat.
		var icon: UIBattlerIcon = create_icon(battler_allegiance, battler.anim.battler_icon)
		battler.readiness_changed.connect(func(readiness: float): icon.progress = readiness / 100.0)
		battler.health_depleted.connect(icon.fade_out)
		
		_icons.add_child(icon)


# Creates a new instance of `UIBattlerIcon`, initializes it, adds it as a child of `background`, and
# returns it.
func create_icon(type: UIBattlerIcon.Types, texture: Texture) -> UIBattlerIcon:
	var icon: UIBattlerIcon = ICON_SCENE.instantiate()
	icon.icon = texture
	icon.battler_type = type
	
	# We calculate where to position the icon, ranging between the left and right limits of the
	# `background` texture. Note this range is only in the X axis: the vector's X and Y components 
	# are the minimum and the maximum icon's X position.
	icon.position_range = Vector2(
		# Offset the range to account for turn bar and battler icon geometry.
		-icon.size.x / 2.0,
		_background.size.x -icon.size.x / 2.0
	)
	
	return icon


## Fade out (to transparent) the turn bar and all of its UI elements.
func fade_out() -> void:
	_anim.play("fade_out")
