class_name InteractionTemplateConversation
extends Interaction

@export var timeline: DialogicTimeline


func interact() -> void:
	if timeline:
		Dialogic.start_timeline(timeline)
