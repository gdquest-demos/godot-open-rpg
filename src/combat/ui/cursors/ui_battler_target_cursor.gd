## Allows the player to choose the targets of a [BattlerAction].
class_name UIBattlerTargetingCursor extends Node2D

## An empty array of [Battler]s passed to targets_selected] when no target is selected.
const INVALID_TARGETS: Array[Battler] = []

## The cursor scene that will be used to denote the active target[s].
const CURSOR_SCENE: = preload("res://src/combat/ui/cursors/ui_menu_cursor.tscn")

## Emitted when the player has selected targets.
## If the player has pressed 'back' instead, [const INVALID_TARGETS] will be returned.[br][br]
## In either case, the cursor will call queue_free() after emitting this signal.
signal targets_selected(selection: Array[Battler])

## Whether the selected action should target all [targets], or only one from the array.
## Currently, this must be set to true or false before filling the [targets] array.
@export var targets_all: = false

## All possible targets for a given action. Generates cursor instances if [targets_all] is true.
@export var targets: Array[Battler] = []:
	set(value):
		targets = value
		if not targets.is_empty():
			if not _current_target in targets:
				_current_target = targets[0]
				_secondary_cursors.erase(_current_target)
			
			# The target list has changed, so "secondary" cursors need to accomodate the new list.
			# Any new Battlers will need a cursor and any removed Battlers should no longer be
			# targeted.
			if targets_all:
				# Remove cursors over targets that are no longer in the target list.
				for battler: Battler in _secondary_cursors.keys():
					if not battler in targets:
						_secondary_cursors[battler].queue_free()
						_secondary_cursors.erase(battler)
				
				# Add cursors to new targets, syncing the animation time.
				for battler: Battler in targets:
					if not battler in _secondary_cursors.keys() and battler != _current_target:
						var new_cursor: = _create_cursor_over_battler(battler)
						if _cursor:
							new_cursor.advance_animation(_cursor.get_animation_position())
						_secondary_cursors[battler] = new_cursor
			
			# Due to processing the tween above, there is a single frame where the cursor will be 
			# stuck at the origin (before the tween updates).
			# Therefore, defer calling show() until after the tween will have processed.
			show.call_deferred()
		
		else:
			_current_target = null

# One of the entries specified by _targets, at which the cursor is located.
var _current_target: Battler = null:
	set(value):
		_current_target = value
		
		if _current_target == null:
			hide()
		
		elif _cursor != null:
			_cursor.move_to(_current_target.anim.top.global_position)

# The primary cursor instance, which is moved from target to target whenever _targets_all is false.
var _cursor: UIMenuCursor = null

# Secondary cursors, which are created whenever _targets_all is true.
# They are children of the UIBattlerTargetingCursor. Dictionary keys are a Battler instance that
# corresponds with one of the targets. This allows the number of cursors to be updated as Battler
# state changes.
# In other words, if targets die or are added while the player is choosing targets, the cursors
# highlighting the targets will update accordingly.
var _secondary_cursors: = {}


func _ready() -> void:
	assert(!targets.is_empty(), "The target cursor needs a non-empty target array!")
	
	hide()
	_cursor = _create_cursor_over_battler(_current_target)
	
	# If the Battler that is currently selecting targets is downed, close the cursor immediately.
	CombatEvents.player_battler_selected.connect(
		func _on_player_battler_selected(_battler: Battler) -> void:
			set_process_unhandled_input(false)
			queue_free()
	)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		# Let the UI know which Battler(s) were selected.
		var highlighted_targets: Array[Battler] = []
		if targets_all:		highlighted_targets.assign(targets)
		else:				highlighted_targets.append(_current_target)
			
		targets_selected.emit(highlighted_targets)
		queue_free()
	
	elif event.is_action_released("back"):
		targets_selected.emit(INVALID_TARGETS)
		queue_free()
	
	# Other keypresses may indicate that the player is selecting another target.
	elif event is InputEventKey:
		# Don't move anything if ALL targets are currently being targeted.
		if targets_all:
			return
		
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


# Creates the actual cursor object over a given battler, or all battlers if targets_all is true.
func _create_cursor_over_battler(target: Battler) -> UIMenuCursor:
	var new_cursor: = CURSOR_SCENE.instantiate() as UIMenuCursor
	add_child(new_cursor)
	
	new_cursor.rotation = PI/2
	new_cursor.global_position = target.anim.top.global_position
	return new_cursor


# Finds the closest battler (that is also in _targets) in a given direction.
# Returns null if no battlers may be found in that direction.
func _find_closest_target(direction: Vector2) -> Battler:
	assert(_current_target, "Target cursor cannot find closest target to a null battler! Current" +
		"target must be non-null.")
	
	var new_target: Battler = null
	var distance_to_new_target: = INF
	
	# First, we find all targetable battlers in a given direction.
	var candidates: Array[Battler] = []
	for battler in targets:
		# Don't select the current target.
		if battler == _current_target:
			continue
		
		# We're going to search within a 90-degree triangle (matching the direction vector +/- 45 
		# degrees) for battlers. Anything outside is excluded, as it is found in a different
		# direction.
		var vector_to_battler: = battler.global_position - _current_target.global_position
		if abs(direction.angle_to(vector_to_battler)) <= PI/2.0:
			candidates.append(battler)
	
	# Secondly, loop over all candidates and find the one closest to the current battler. 
	# That is our new target.
	for battler in candidates:
		var distance_to_battler: = global_position.distance_to(battler.global_position)
		if distance_to_battler < distance_to_new_target:
			distance_to_new_target = distance_to_battler
			new_target = battler
	
	return new_target
