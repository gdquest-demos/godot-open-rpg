extends Cutscene

@export var timeline: DialogicTimeline

@onready var _bg: ColorRect = $Background/ColorRect
@onready var _timer: Timer = $DelayTimer


func _execute() -> void:
	# Wait briefly before starting the script logic.
	_timer.start()
	await _timer.timeout
	
	await get_tree().process_frame
	await Transition.clear(0.0)
	
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended
	
	await Transition.cover()
	_bg.hide()
	
	Music.play(load("res://assets/music/Apple Cider.mp3"))
	await Transition.clear(2.0)
	
	queue_free.call_deferred()
