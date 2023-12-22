@tool

class_name InteractionTemplateConversation
extends Interaction

@export var timeline: DialogicTimeline


func _execute() -> void:
	if timeline:
		Dialogic.start_timeline(timeline)
		
		# Wait for the timeline to finish before ending the event. Note that we also wait a single
		# frame afterwards to prevent input for repeating the event.
		await Dialogic.timeline_ended
		await get_tree().process_frame
