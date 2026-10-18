@tool

extends Interaction

@export var pre_combat_timeline: DialogicTimeline
@export var victory_timeline: DialogicTimeline
@export var loss_timeline: DialogicTimeline

@export var combat_arena: PackedScene


func _execute() -> void:
	Dialogic.start_timeline(pre_combat_timeline)
	
	# Wait for the timeline to finish before beginning combat.
	await Dialogic.timeline_ended
	
	# Let other systems know that a combat has been triggered and then wait for its outcome.
	FieldEvents.combat_triggered.emit.call_deferred(combat_arena)
