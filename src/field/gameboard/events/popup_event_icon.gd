@tool

class_name EventIcon
extends Area2D

signal state_changed(state: State)

enum State { SHOWN, APPEARING, HIDDEN, DISAPPEARING }

@export var detect_radius: = 48.0:
	set(value):
		detect_radius = value
		
		if not is_inside_tree():
			await ready
		
		_shape.shape.radius = detect_radius

@export var appear_time: = 0.4
@export var disappear_time: = 0.2

var _scale_factor: = 1.0:
	set(value):
		_scale_factor = value
		
		for child in get_children():
			if not child == _shape and child.get("scale"):
				child.scale = Vector2(_scale_factor, _scale_factor)

var _scale_tween: Tween

var _state: = State.HIDDEN:
	set(value):
		if value != _state:
			_state = value
			state_changed.emit(_state)

@onready var _shape: = $CollisionShape2D as CollisionShape2D


func _ready() -> void:
	_shape.shape = CircleShape2D.new()
	_shape.shape.radius = detect_radius
	
	if not Engine.is_editor_hint():
		var interaction: = get_parent() as Interaction
		assert(interaction, "EventIcon expects an Interaction as parent. Current parent is named "
			+ " %s." % get_parent().name)
		
		area_entered.connect(_on_area_entered)
		area_exited.connect(_on_area_exited)
		
#		_anim.play("hide")
		_scale_factor = 0.0
		_state = State.HIDDEN


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not get_parent() is Interaction:
		warnings.append("EventIcon expects an Interaction as parent.")
	
	return warnings


func _appear() -> void:
	if _scale_factor < 1.0:
		if _scale_tween:
			_scale_tween.kill()
		_scale_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		
		_state = State.APPEARING
		
		_scale_tween.tween_property(self, "_scale_factor", 1.0, appear_time * (1.0-_scale_factor))
		_scale_tween.tween_callback(func(): _state = State.SHOWN)


func _disappear() -> void:
	if _scale_factor > 0.0:
		if _scale_tween:
			_scale_tween.kill()
		_scale_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		
		_state = State.DISAPPEARING
		
		_scale_tween.tween_property(self, "_scale_factor", 0.0, appear_time * _scale_factor)
		_scale_tween.tween_callback(func(): _state = State.HIDDEN)


# If the popup is hidden when something triggers the area2D, show the popup.
func _on_area_entered(_area: Area2D) -> void:
	if _state == State.HIDDEN or _state == State.DISAPPEARING:
		_appear()


# If everything has left the area2D yet it is visible, hide the popup.
func _on_area_exited(_area: Area2D) -> void:
	if get_overlapping_areas().is_empty() and (_state == State.SHOWN or _state == State.APPEARING):
		_disappear()


# If the animation has finished playing but there has been a change in the area2d, modify its state.
#func _on_animation_finished(_anim_name: String) -> void:
#	var has_player_in_radius: = not get_overlapping_areas().is_empty()
#	if _state == State.HIDDEN and has_player_in_radius:
#		_anim.play("appear")
#		_state = State.SHOWN
#
#	elif _state == State.SHOWN and not has_player_in_radius:
#		_anim.play("disappear")
#		_state = State.HIDDEN
