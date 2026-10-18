extends Cutscene

@export var timeline: DialogicTimeline


func _execute() -> void:
	await Transition.clear(0.4)
	Dialogic.start_timeline(timeline)
	
	# Wait for the timeline to finish before beginning combat.
	await Dialogic.timeline_ended
