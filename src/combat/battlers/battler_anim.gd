@tool
class_name BattlerAnim extends Marker2D

## Dictates how far the battler moves forwards and backwards at the beginning/end of its turn.
const MOVE_OFFSET: = 40.0

## Determines which direction the battler faces on the screen.
enum Direction { LEFT, RIGHT }

## Emitted whenever an action-based animation wants to apply an effect. May be triggered multiple
## times per animation.
@warning_ignore("unused_signal")
signal action_triggered

## Forward AnimationPlayer's same signal.
signal animation_finished(name)

## Determines which direction the [BattlerAnim] faces. This is generally set by whichever "side"
## the battler is on, player or enemy.
@export var direction: = Direction.RIGHT

## Determines the time it takes for the [BattlerAnim] to slide forward or backward when its turn
## comes up.
@export var select_move_time: = 0.3

var _move_tween: Tween = null
var _rest_position: = Vector2.ZERO

var _battler: Battler:
	set(value):
		# If this object had a previous battler parent and had connected to its signals, disconnect
		# these before setting the new parent.
		if _battler and not Engine.is_editor_hint():
			if _battler.selection_toggled.is_connected(_on_battler_selection_toggled):
				_battler.selection_toggled.disconnect(_on_battler_selection_toggled)
		
		_battler = value
		if _battler and not Engine.is_editor_hint():
			_battler.selection_toggled.connect(_on_battler_selection_toggled)
		
		update_configuration_warnings()

@onready var _anim: = $Pivot/AnimationPlayer as AnimationPlayer


func _ready() -> void:
	_anim.animation_finished.connect(_on_animation_player_finished)
	
	_rest_position = position


func _notification(msg: int) -> void:
	if msg == NOTIFICATION_PARENTED:
		_battler = get_parent() as Battler


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: = []
	if not _battler:
		warnings.append("Requires a Battler as a parent to function correctly!")
	
	return warnings


# Functions that wraps around the animation players' `play()` function, delegating the work to the
# `AnimationPlayerDamage` node when necessary.
func play(anim_name: String) -> void:
	assert(_anim.has_animation(anim_name), "Battler animation '%s' does not have animation '%s'!"
		% [name, anim_name])
	
	_anim.play(anim_name)
	#if anim_name == "take_damage":
		#anim_player_damage.play(anim_name)
		## Seeking back to 0 restarts the animation if it is already playing.
		#anim_player_damage.seek(0.0)
	#else:
		#anim_player.play(anim_name)

## Returns true if an animation is currently playing, otherwise returns false.
func is_playing() -> bool:
	return _anim.is_playing()


## Queues the specified animation sequence and plays it if the animation player is stopped.
func queue_animation(anim_name: String) -> void:
	assert(_anim.has_animation(anim_name), "Battler animation '%s' does not have animation '%s'!"
		% [name, anim_name])
	
	_anim.queue(anim_name)
	if not _anim.is_playing():
		_anim.play()


## Tween the object [constant MOVE_OFFSET] pixels from its rest position towards enemy [Battler]s.
func move_forward(duration: float) -> void:
	if _move_tween:
		_move_tween.kill()
	
	_move_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	_move_tween.tween_property(
		self, 
		"position", 
		_rest_position + Vector2.LEFT*scale.x*MOVE_OFFSET,
		duration
	)


## Tween the object back to its rest position.
func move_to_rest(duration: float) -> void:
	if _move_tween:
		_move_tween.kill()
	
	_move_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	_move_tween.tween_property(
		self, 
		"position", 
		_rest_position,
		duration
	)


func _on_animation_player_finished(anim_name: String) -> void:
	animation_finished.emit(anim_name)


func _on_battler_selection_toggled(value: bool) -> void:
	if value:
		move_forward(select_move_time)
	
	else:
		move_to_rest(select_move_time)
