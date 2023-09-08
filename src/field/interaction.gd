@icon("res://assets/editor/icons/Interaction.svg")
class_name Interaction extends Area2D

@export var text_layout: DialogicNode_Style

@export var is_active: = true:
	set(value):
		is_active = value
		monitoring = is_active
		monitorable = is_active
		
		_update_input_state()
		
		if not is_inside_tree():
			await ready
		
		# We use "Visible Collision Shapes" to debug positions on the gameboard, so we'll want to
		# change the state of child collision shapes as well.
		# These could be either CollisionShape2Ds or CollisionPolygon2Ds.
		for node in find_children("*", "CollisionShape2D"):
			(node as CollisionShape2D).disabled = !is_active
		for node in find_children("*", "CollisionPolygon2D"):
			(node as CollisionPolygon2D).disabled = !is_active

# 
static var _running_event_is_blocking: = false

# Track overlapping areas. Determining whether or not to run an event is not as simple as the
# presence of overlapping areas, since factors such as gamestate and the existence of another
# running events are relevant.
var _overlapping_areas: = []


func _ready():
	set_process_unhandled_input(false)
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("interact"):
		interact()


static func are_events_blocked() -> bool:
	return _running_event_is_blocking


func interact() -> void:
	print(Dialogic.VAR.PlayerName)
	text_layout.show()
	Dialogic.start_timeline(preload("res://data/dialogic/timeline.dtl"))
	await Dialogic.timeline_ended
	print("Done!")
	text_layout.hide()


func _update_input_state() -> void:
	var is_runnable: bool = is_active and not _overlapping_areas.is_empty()
	set_process_unhandled_input(is_runnable)
	
	if is_runnable:
		print("Can run interaction")
	else:
		print("Cannot run interaction")


# Find when player interaction shape eneters and enable input, if active
func _on_area_entered(area: Area2D) -> void:
	if not area in _overlapping_areas:
		_overlapping_areas.append(area)
	
	_update_input_state()


func _on_area_exited(area: Area2D) -> void:
	_overlapping_areas.erase(area)
	_update_input_state()
