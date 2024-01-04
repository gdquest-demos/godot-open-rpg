@tool

class_name InteractionTemplateConversation extends Interaction

@export var timeline: DialogicTimeline


func _execute() -> void:
	if timeline:
		Dialogic.start_timeline(timeline)
		
		# Wait for the timeline to finish before ending the event.
		await Dialogic.timeline_ended
