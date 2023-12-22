@tool
class_name UIPopup extends Node2D

enum IconTypes { EMPTY, EXCLAMATION, QUESTION}

# The current state of a popup.
enum States { HIDDEN, SHOWN, HIDING, SHOWING}

const Emotes: = {
	IconTypes.EMPTY: preload("res://assets/gui/emotes/emote__.png"),
	IconTypes.EXCLAMATION: preload("res://assets/gui/emotes/emote_exclamations.png"),
	IconTypes.QUESTION: preload("res://assets/gui/emotes/emote_question.png"),
}

@export var emote: IconTypes:
	set(value):
		emote = value
		
		if not is_inside_tree():
			await ready
		
		_sprite.texture = Emotes.get(emote, Emotes[IconTypes.EMPTY])

# The target state of the popup. Setting it to true or false will cause a change in behaviour.
# True if the popup should be shown or false if the popup should be hidden.
# Note that this shows the TARGET state of the popup, so _is_shown may be false even while the
# popup is appearing.
var _is_shown: = false:
	set(value):
		_is_shown = value
		if _is_shown and _state == States.HIDDEN:
			_anim.play("appear")
			_state = States.SHOWING

# Track what is currently happening to the popup.
var _state: = States.HIDDEN

@onready var _anim: = $AnimationPlayer as AnimationPlayer
@onready var _sprite: = $Sprite2D as Sprite2D


func _ready() -> void:
	if not Engine.is_editor_hint():
		_sprite.scale = Vector2.ZERO
		_anim.animation_finished.connect(_on_animation_finished)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_focus_next"):
		_is_shown = !_is_shown


# An animation has finished, so we may want to change the popup's behaviour depending on whether or
# not it has been flagged for a state change through _is_shown.
func _on_animation_finished(_anim_name: String) -> void:
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
