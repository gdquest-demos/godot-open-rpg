@tool
## An animated pop-up graphic. These are often found, for example, in dialogue bubbles to
## demonstrate the need for player input.
class_name UIPopup extends Node2D

## Emitted when the popup has completely disappeared.
signal disappeared

## The states in which a popup may exist.
enum States { HIDDEN, SHOWN, HIDING, SHOWING}

# The target state of the popup. Setting it to true or false will cause a change in behaviour.
# True if the popup should be shown or false if the popup should be hidden.
# Note that this shows the TARGET state of the popup, so _is_shown may be false even while the
# popup is appearing.
var _is_shown: = false:
	set(value):
		_is_shown = value
		
		if not is_inside_tree():
			await ready
		
		if _is_shown and _state == States.HIDDEN:
			_anim.play("appear")
			_state = States.SHOWING
		
		# A fully shown, idling popup bounces slightly to draw the player's eye. Note that there is
		# a small wait time between bounces so that the popup doesn't look overly energetic.
		# Unfortunately, this creates an edge case for smooth animation (see _on_bounce_finished). 
		#
		# Basically, if the bounce animation isn't playing, but the popup is waiting for the next 
		# 'bounce', we want to be able to hide the popup immediately, rather than wait for 'wait'
		# a fraction of a second for the animation to finish playing, which looks 'off'.
		#
		# So, we check here to see if the popup is sitting in this 'wait' window, where it can be
		# immediately hidden and still look smooth as butter.
		elif not _is_shown and _anim.current_animation == "bounce_wait":
			_anim.play("disappear")
			_state = States.HIDING

# Track what is currently happening to the popup.
var _state: = States.HIDDEN

@onready var _anim: = $AnimationPlayer as AnimationPlayer
@onready var _sprite: = $Sprite2D as Sprite2D


func _ready() -> void:
	if not Engine.is_editor_hint():
		_sprite.scale = Vector2.ZERO
		_anim.animation_finished.connect(_on_animation_finished)


## Wait for the popup to disappear cleanly before freeing. If the popup is already hidden, it may be
## freed immediately.
## This is useful for smoothly removing a poup from an external object.
func hide_and_free() -> void:
	if _state != States.HIDDEN:
		_is_shown = false
		await disappeared
	queue_free()


# Please see the note attached embedded in _is_shown's setter.
# A peculiarity of the bounce animation is that there is a wait time afterwards before the next
# bounce. However, it doesn't look 'right' to wait to hide the popup until the animation has 
# finished when the bounce and wait are baked together into a single animation. Ideally, we should 
# be able to hide the popup whenever it's not growing or shrinking (or bouncing).
#
# Therefore, the bounce animation will check, via the following method, for whether or not the wait
# portion of the animation should be played or if the popup should disappear beforehand.
func _on_bounce_finished() -> void:
	if _is_shown:
		_anim.play("bounce_wait")
		
	else:
		_anim.play("disappear")
		_state = States.HIDING


# An animation has finished, so we may want to change the popup's behaviour depending on whether or
# not it has been flagged for a state change through _is_shown.
func _on_animation_finished(_anim_name: String) -> void:
	if _state == States.HIDING:
		disappeared.emit()
	
	# The popup has should be shown. If the popup is hiding or is hidden, go ahead and have it
	# appear. Otherwise, the popup can play a default bouncy animation to draw the player's eye.
	if _is_shown:
		match _state:
			States.HIDING, States.HIDDEN:
				_anim.play("appear")
				_state = States.SHOWING
			_:
				_anim.play("bounce")
				_state = States.SHOWN
	
	# The popup should be hidden. If it has just appeared, cause it to disappear. Otherwise just
	# flag it as hidden.
	else:
		match _state:
			States.SHOWING, States.SHOWN:
				_anim.play("disappear")
				_state = States.HIDING
			_:
				_state = States.HIDDEN
