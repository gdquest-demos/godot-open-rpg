extends Control

signal target_selected(battler)

onready var anim_player = $Sprite/AnimationPlayer
onready var tween = $Tween

export var MOVE_DURATION : float = 0.1

const DIRECTION_UP = Vector2(0.0, -1.0)
const DIRECTION_LEFT = Vector2(-1.0, 0.0)
const DIRECTION_RIGHT = Vector2(1.0, 0.0)
const DIRECTION_DOWN = Vector2(0.0, 1.0)

var targets : Array
var target_active : Battler

func _ready():
	hide()

func select_targets(battlers : Array) -> Array:
	"""
	Currently the arrow only allows you to select one target
	Returns an array containing the target
	"""
	visible = true
	targets = battlers
	target_active = targets[0]
	rect_scale.x = 1.0 if target_active.party_member else -1.0
	rect_global_position = target_active.target_global_position
	anim_player.play("wiggle")
	grab_focus()
	var selected_target : Battler = yield(self, "target_selected")
	hide()
	if not selected_target:
		return []
	return [selected_target]

func move_to(battler : Battler):
	tween.interpolate_property(
		self,
		'rect_global_position', 
		rect_global_position,
		battler.target_global_position,
		MOVE_DURATION,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT)
	tween.start()

func _gui_input(event):
	if !visible:
		return
	
	if event.is_action_pressed("ui_accept"):
		emit_signal("target_selected", target_active)
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		emit_signal("target_selected", null)
		get_tree().set_input_as_handled()
	
	var new_target : Battler = null
	if event.is_action_pressed("ui_left"):
		new_target = find_closest_target(DIRECTION_LEFT)
		accept_event()
	if event.is_action_pressed("ui_up"):
		new_target = find_closest_target(DIRECTION_UP)
		accept_event()
	if event.is_action_pressed("ui_right"):
		new_target = find_closest_target(DIRECTION_RIGHT)
		accept_event()
	if event.is_action_pressed("ui_down"):
		new_target = find_closest_target(DIRECTION_DOWN)
		accept_event()
	if not new_target:
		return
	target_active = new_target
	move_to(target_active)

func find_closest_target(direction : Vector2) -> Battler:
	"""
	Returns the closest target in the given direction
	Use DIRECTION_* constants
	"""
	var selected_target : Battler = null
	var distance_to_selected : float = 100000.0

	print('')
	print('Distance to selected: %s' % distance_to_selected)
	# Filter battlers to prioritize those in the given direction
	var priority_battlers : Array
	var other_battlers : Array
	for battler in targets:
		var to_battler : Vector2 = battler.global_position - target_active.global_position
		if to_battler.length() < 1.0:
			continue
		var abs_angle_to_battler = abs(direction.angle_to(to_battler))
		if abs_angle_to_battler > PI / 2.0:
			continue
		if abs_angle_to_battler < PI / 6.0:
			priority_battlers.append(battler)
		else:
			other_battlers.append(battler)
	
	# Select in a cone
	for battler in priority_battlers:
		var distance : float = battler.global_position.distance_to(target_active.global_position)
		selected_target = battler
		distance_to_selected = distance
	if selected_target:
		return selected_target
	
	# If no battlers in the narrow cone,
	# select by lowest distance along the direction vector's axis
	var axis : String = 'x' if direction in [DIRECTION_LEFT, DIRECTION_RIGHT] else 'y'
	var compare_direction : float = direction.x if axis == 'x' else direction.y
	for battler in other_battlers:
		var to_battler : Vector2 = battler.global_position - target_active.global_position
		var distance : float = abs(to_battler.x) if axis == 'x' else abs(to_battler.y)
	return selected_target
