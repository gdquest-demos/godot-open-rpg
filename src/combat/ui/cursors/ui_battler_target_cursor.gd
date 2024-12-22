class_name UIBattlerTargetingCursor extends Marker2D

## The time taken to move the cursor from one [Battler] to the next.
const SLIDE_TIME: = 0.1

# The tween used to move the cursor from Battler to Battler.
var _slide_tween: Tween = null

# All possible targets for a given action.
var _targets: Array[Battler] = []

# One of the entries specified by _targets, at which the cursor is located.
var _current_target: Battler = null:
	set(value):
		_current_target = value
		
		if _current_target == null:
			hide()
		
		else:
			_move_to(_current_target.anim.front.global_position)


func _ready() -> void:
	# The arrow needs to move indepedently from its parent.
	set_as_top_level(true)
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		CombatEvents.player_targets_selected.emit([_current_target])
		queue_free()
	
	elif event.is_action_released("ui_cancel"):
		CombatEvents.player_targets_selected.emit([])
		queue_free()
	
	# Other keypresses may indicate that the player is selecting another target.
	elif event is InputEventKey:
		var direction: = Vector2.ZERO
		if event.is_action_released("ui_left"):
			direction = Vector2.LEFT
		elif event.is_action_released("ui_right"):
			direction = Vector2.RIGHT
		elif event.is_action_released("ui_up"):
			direction = Vector2.UP
		elif event.is_action_released("ui_down"):
			direction = Vector2.DOWN
		
		if not direction.is_equal_approx(Vector2.ZERO):
			var new_target: = _find_closest_target(direction)
			if new_target:
				_current_target = new_target


## Designate all possible targets that may be selected and set the cursor to the first entry.
func setup(possible_targets: Array[Battler]) -> void:
	_targets = possible_targets
	
	if not _targets.is_empty():
		_current_target = _targets[0]
		
		# We want the arrow to appear immediately at the targert, so advance the tween to its end.
		_slide_tween.custom_step(SLIDE_TIME)
		
		# Due to processing the tween above, there is a single frame where the cursor will be stuck
		# at the origin (before the tween updates).
		# Therefore, defer calling show() until after the tween will have processed.
		show.call_deferred()


# Finds the closest battler (that is also in _targets) in a given direction.
# Returns null if no battlers may be found in that direction.
func _find_closest_target(direction: Vector2) -> Battler:
	var new_target: Battler = null
	var distance_to_new_target: = INF
	
	# First, we find all targetable battlers in a given direction.
	var candidates: Array[Battler] = []
	for battler in _targets:
		# Don't select the current target.
		if battler == _current_target:
			continue
		
		# We're going to search within a 90-degree triangle (matching the direction vector +/- 45 
		# degrees) for battlers. Anything outside is excluded, as it is found in a different
		# direction.
		var vector_to_battler: = battler.global_position - global_position
		if abs(direction.angle_to(vector_to_battler)) <= PI/4.0:
			candidates.append(battler)
	
	# Secondly, loop over all candidates and find the one closest to the current battler. 
	# That is our new target.
	for battler in candidates:
		var distance_to_battler: = global_position.distance_to(battler.global_position)
		if distance_to_battler < distance_to_new_target:
			distance_to_new_target = distance_to_battler
			new_target = battler
	
	return new_target


# Smoothly move the cursor to an arbitrary position. Called whenever _current_target changes.
func _move_to(target_position: Vector2) -> void:
	if _slide_tween:
		_slide_tween.kill()
	_slide_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	# Move the cursor to the target position...
	_slide_tween.tween_property(self, "position", target_position, SLIDE_TIME)
	
	# ...and halfway through the movement, flip the arrow's orientation to correspond to whether or
	# not the target is an enemy or friendly battler.
	_slide_tween.parallel().tween_callback(
		func _flip_arrow() -> void:
			scale.x = 1.0 if _current_target.is_player else -1.0
	).set_delay(SLIDE_TIME/2.0)
