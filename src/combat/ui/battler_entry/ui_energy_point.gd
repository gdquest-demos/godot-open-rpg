## A single energy point UI element, animating smoothly as a player Battler gains and spends energy.
extends MarginContainer

## When highlighted, the point indicator will be offset by the following amount.
const SELECTED_OFFSET := Vector2(0.0, -6.0)

## The time required to move the point to or from [constant SELECTED_OFFSET].
const SELECT_TIME: = 0.2

## The time required to fade in or out the filled point.
const FADE_TIME: = 0.3

var _color_tween: Tween = null
var _offset_tween: Tween = null

@onready var _fill: = $EnergyPoint/Fill as TextureRect

# We store the start modulate value of the `Fill` node because it's semi-transparent.
# This way, we can animate the color from and to this value.
@onready var _color_transparent := _fill.modulate


## Animate the point fill texture to fully opaque.
func appear() -> void:
	if _color_tween:
		_color_tween.kill()
	_color_tween = create_tween()
	_color_tween.tween_property(_fill, "modulate", Color.WHITE, FADE_TIME)


## Animate the point fill texture to mostly-transparent.
func disappear() -> void:
	if _color_tween:
		_color_tween.kill()
	_color_tween = create_tween()
	_color_tween.tween_property(_fill, "modulate", _color_transparent, FADE_TIME)


func select() -> void:
	if _offset_tween:
		_offset_tween.kill()
	_offset_tween = create_tween()
	_offset_tween.tween_property(_fill, "position", SELECTED_OFFSET, SELECT_TIME)


func deselect() -> void:
	if _offset_tween:
		_offset_tween.kill()
	_offset_tween = create_tween()
	_offset_tween.tween_property(_fill, "position", Vector2.ZERO, SELECT_TIME)
