@tool

## A [Cutscene] that is triggered by the presence of the player and the player's input.
##
## An active Interaction may be run by the player walking up to it and 'interacting' with it,
## usually via something as ubiquitous as the spacebar key. Common examples found in most RPGs are
## NPC conversations, opening treasure chests, activating a save point, etc.
##
##[br][br]
## Interactions handle player input directly and are activated according to the presence of the
## player's interaction collision shape, which occupies the cell faced by the player's character.
@icon("res://assets/editor/icons/Interaction.svg")
class_name Interaction extends Cutscene

## An active [code]Interaction[/code] may be run, whereas one that is inactive may only be run
## directly through code via the [method Cutscene.run] method.
@export var is_active: = true:
	set(value):
		is_active = value
		
		if not Engine.is_editor_hint():
			_update_input_state()
			
			if not is_inside_tree():
				await ready
			
			# We use "Visible Collision Shapes" to debug positions on the gameboard, so we'll want 
			# to change the state of child collision shapes.These could be either CollisionShape2Ds
			# or CollisionPolygon2Ds.
			# Note that we only want to disable the collision shapes of objects that are actually
			# connected to this Interaction.
			for data in get_incoming_connections():
				var callable: = data["callable"] as Callable
				if callable == _on_area_entered :
					var connected_area: = data["signal"].get_object() as Area2D
					if connected_area:
						for node in connected_area.find_children("*", "CollisionShape2D"):
							(node as CollisionShape2D).disabled = !is_active
						for node in connected_area.find_children("*", "CollisionPolygon2D"):
							(node as CollisionPolygon2D).disabled = !is_active

# Track overlapping areas. Determining whether or not to run an event is not as simple as the
# presence of overlapping areas, since factors such as gamestate and the existence of another
# running events are relevant.
var _overlapping_areas: = []


func _ready():
	set_process_unhandled_input(false)
	
	if not Engine.is_editor_hint():
		FieldEvents.input_paused.connect(_on_input_paused)


# Ensure that something is connected to _on_area_entered and _on_area_exited, which the Interaction
#  requires. If nothing is connected, issue a configuration warning.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	var has_area_entered_bindings: = false
	var has_area_exited_bindings: = false
	
	for data in get_incoming_connections():
		var callable: = data["callable"] as Callable
		if callable == _on_area_entered :
			has_area_entered_bindings = true
		elif callable == _on_area_exited:
			has_area_exited_bindings = true
	
	if not has_area_entered_bindings:
		warnings.append("This object does not have a CollisionObject2D's signals connected to " + 
			"this Interactions's _on_area_entered method. The Interaction is not interactable!")
	if not has_area_exited_bindings:
		warnings.append("This object does not have a CollisionObject2D's signals connected to " + 
			"this Interactions's _on_area_exited method. The Interaction can never turn off!")
	return warnings


# An Interaction only processes input when its childrens' collision shape(s) have collided with the
# player's interaction collision shape.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("interact"):
		run()


# Determine whether or not an Interaction is runnable, due to the presence of the player's
# interaction shape and whether or not the Interaction is active.
func _update_input_state() -> void:
	var is_runnable: bool = is_active and not _overlapping_areas.is_empty()
	set_process_unhandled_input(is_runnable)


# Pause any collision objects that would normally send signals regarding interactions.
# This will automatically accept or ignore currently overlapping areas.
func _on_input_paused(is_paused: bool) -> void:
	for data in get_incoming_connections():
		# Note that we only want to check _on_area_entered, since _on_area_exited will clean up any
		# lingering references once the Area2Ds are 'shut off' (i.e. not monitoring/monitorable).
		if data["callable"] == _on_area_entered:
			var connected_area: = data["signal"].get_object() as Area2D
			if connected_area:
				connected_area.monitoring = !is_paused
				connected_area.monitorable = !is_paused


# Find the entering player interaction shape and enable input, if the interaction is active.
func _on_area_entered(area: Area2D) -> void:
	if not Engine.is_editor_hint():
		if not area in _overlapping_areas:
			_overlapping_areas.append(area)
		
		_update_input_state()


# Clean up any references to the player's interaction collision shape.
func _on_area_exited(area: Area2D) -> void:
	if not Engine.is_editor_hint():
		_overlapping_areas.erase(area)
		_update_input_state()
