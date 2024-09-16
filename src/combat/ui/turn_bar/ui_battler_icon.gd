@tool
class_name UIBattlerIcon extends TextureRect

## Describe the type of Battler represented by the icon:
##<br> - Allies are friendly battlers that are not controlled by the player.
##<br> - Player battlers are almost always player-controlled (unless asleep/berzerked, for example).
##<br> - Enemy battlers act against the player and must be defeated.
enum Types { ALLY, PLAYER, ENEMY }

const PORTRAIT_BACKS: = {
	Types.ALLY: preload("portrait_bg_ally.png"),
	Types.PLAYER: preload("portrait_bg_player.png"),
	Types.ENEMY: preload("portrait_bg_enemy.png"),
}

@export var battler_type: Types:
	set(value):
		battler_type = value
		texture = PORTRAIT_BACKS.get(battler_type)

@export var icon: Texture:
	set(value):
		icon = value
		
		if not is_inside_tree():
			await ready
		_icon.texture = icon

## The upper and lower bounds describing the UIBattlerIcon's movement along the x-axis.
## The icon moves along the turn bar, whose size is used to determine where and how far the icon
## may move.
@export var position_range := Vector2.ZERO:
	set(value):
		position_range = value
		position.x = lerpf(position_range.x, position_range.y, progress)

## Determines where on the turn bar the icon is currently located. The value is clamped between 0
## and 1.
@export var progress: = 0.0:
	set(value):
		progress = clampf(value, 0.0, 1.0)
		position.x = lerpf(position_range.x, position_range.y, progress)

@onready var _anim: = $AnimationPlayer as AnimationPlayer
@onready var _icon: = $Icon as TextureRect


func fade_out() -> void:
	_anim.play("fade_out")
