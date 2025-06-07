extends Cutscene

@export var timeline: DialogicTimeline


func _execute() -> void:
	$Background/ColorRect.show()
	
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended
	
	await Transition.cover()
	$Background/ColorRect.hide()
	
	Music.play(load("res://assets/music/Apple Cider.mp3"))
	await Transition.clear(2.0)
	
	queue_free.call_deferred()
