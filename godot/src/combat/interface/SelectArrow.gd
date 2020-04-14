extends Control

signal target_selected(battler)

onready var anim_player = $Sprite/AnimationPlayer
onready var tween = $Tween

export var MOVE_DURATION: float = 0.1

const DIRECTION_UP = Vector2(0.0, -1.0)
const DIRECTION_LEFT = Vector2(-1.0, 0.0)
const DIRECTION_RIGHT = Vector2(1.0, 0.0)
const DIRECTION_DOWN = Vector2(0.0, 1.0)

var targets: Array
var target_active: Battler


func select_targets(battlers: Array) -> Array:
	# Currently the arrow only allows you to select one target
	# Returns an array containing the target
	visible = true
	targets = battlers
	target_active = targets[0]
	rect_scale.x = 1.0 if target_active.party_member else -1.0
	rect_global_position = target_active.target_global_position
	anim_player.play("wiggle")
	grab_focus()
	var selected_target: Battler = yield(self, "target_selected")
	hide()
	targets = []
	if not selected_target:
		return []
	return [selected_target]


func move_to(battler: Battler):
	tween.interpolate_property(
		self,
		'rect_global_position',
		rect_global_position,
		battler.target_global_position,
		MOVE_DURATION,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT
	)
	tween.start()


# Mouse and touch controls
func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if not event.is_action_pressed("ui_accept"):
		return
	for battler in targets:
		if not battler.has_point(event.position):
			continue
		if battler == target_active:
			emit_signal("target_selected", target_active)
		else:
			target_active = battler
			move_to(target_active)
	accept_event()
	return


func _gui_input(event):
	if ! visible:
		return

	if event.is_action_pressed("ui_accept"):
		emit_signal("target_selected", target_active)
		accept_event()
	elif event.is_action_pressed("ui_cancel"):
		emit_signal("target_selected", null)
		accept_event()

	var new_target: Battler = null
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


func find_closest_target(direction: Vector2) -> Battler:
	# Returns the closest target in the given direction
	# Use DIRECTION_* constants
	if targets.size() == 1:
		return targets[0]
	var selected_target: Battler = null
	var distance_to_selected: float = 100000.0

	# Filter battlers to prioritize those in the given direction
	var priority_battlers: Array = []
	var other_battlers: Array = []
	for battler in targets:
		var to_battler: Vector2 = battler.global_position - target_active.global_position
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
		var distance: float = battler.global_position.distance_to(target_active.global_position)
		selected_target = battler
		distance_to_selected = distance
	if selected_target:
		return selected_target

	# If no battlers in the narrow cone,
	# select by lowest distance along the direction vector's axis
	var axis: String = 'x' if direction in [DIRECTION_LEFT, DIRECTION_RIGHT] else 'y'
	var compare_direction: float = direction.x if axis == 'x' else direction.y
	for battler in other_battlers:
		var to_battler: Vector2 = battler.global_position - target_active.global_position
		var distance: float = abs(to_battler.x) if axis == 'x' else abs(to_battler.y)
		if distance < distance_to_selected:
			selected_target = battler
			distance_to_selected = distance
	return selected_target
