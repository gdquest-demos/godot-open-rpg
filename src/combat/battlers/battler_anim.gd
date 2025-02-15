## The visual representation of a [Battler].
##
## Battler animations respond visually to a closed set of stimiuli, such as receiving a hit or 
## moving to a position. These animations often represent a single character or a class of enemies
## and are added as children to a given Battler.
##
## [br][br]Note: BattlerAnims must be children of a Battler object to function correctly!
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

## An icon that shows up on the turn bar.
@export var battler_icon: Texture

## Determines which direction the [BattlerAnim] faces. This is generally set by whichever "side"
## the battler is on, player or enemy.
@export var direction: = Direction.RIGHT:
	set(value):
		direction = value
		
		scale.x = 1
		if direction == Direction.LEFT:
			scale.x = -1

## Determines the time it takes for the [BattlerAnim] to slide forward or backward when its turn
## comes up.
@export var select_move_time: = 0.3

var _move_tween: Tween = null
var _rest_position: = Vector2.ZERO

@onready var front: = $FrontAnchor as Marker2D
@onready var top: = $TopAnchor as Marker2D

@onready var _anim: = $Pivot/AnimationPlayer as AnimationPlayer


func _ready() -> void:
	_anim.animation_finished.connect(
		func _on_animation_player_finished(anim_name: String) -> void:
			animation_finished.emit(anim_name)
	)
	
	_rest_position = position


## Setup the BattlerAnim object to respond to gameplay signals from a [Battler] class.
func setup(battler: Battler, facing: Direction) -> void:
	# BattlerAnim objects are assigned in-editor and created dynamically both in-game and in-editor.
	# We do not want the BattlerAnim objects to be saved with the CombatArena scenes, since they are
	# instantiated at runtime, so they should not be assigned an owner when in the editor.
	# However, in gameplay the BattlerAnim class must have an owner, as these objects need to be
	# discoverable by Node::find_children(). This allows us to wait for animations to finish playing
	# before ending combat, for example.
	if not Engine.is_editor_hint():
		owner = battler
	
	direction = facing
	
	battler.health_depleted.connect(
		func _on_battler_health_depleted() -> void:
			_anim.play("die")
	)
	battler.hit_received.connect(
		func _on_battler_hit_received(value: int) -> void:
			if value > 0: _anim.play("hurt")
	)
	battler.selection_toggled.connect(
		func _on_battler_selection_toggled(value) -> void:
			if value: move_forward(select_move_time)
			else: move_to_rest(select_move_time)
	)


## A function that wraps around the animation players' `play()` function, delegating the work to the
## `AnimationPlayerDamage` node when necessary.
func play(anim_name: String) -> void:
	assert(_anim.has_animation(anim_name), "Battler animation '%s' does not have animation '%s'!"
		% [name, anim_name])
	
	_anim.play(anim_name)


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
