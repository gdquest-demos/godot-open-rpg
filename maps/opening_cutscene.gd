extends Cutscene

@export var timeline: DialogicTimeline

@onready var _screen_transition: = $CanvasLayer/ScreenTransition as ScreenTransition


func _execute() -> void:
	_screen_transition.cover()
	
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended
	
	Music.play(load("res://assets/music/Apple Cider.mp3"))
	_screen_transition.reveal(2.0)
	await _screen_transition.finished
	
	queue_free.call_deferred()
