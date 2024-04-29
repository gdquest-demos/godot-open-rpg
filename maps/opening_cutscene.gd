extends Cutscene

@export var timeline: DialogicTimeline


func _execute() -> void:
	Transition.cover()
	
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended
	
	Music.play(load("res://assets/music/Apple Cider.mp3"))
	Transition.clear(2.0)
	await Transition.finished
	
	queue_free.call_deferred()
