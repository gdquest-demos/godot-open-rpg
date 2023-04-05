## An FPS counter that updates at a determined frequency.
extends Label

@export var update_frequency: = 2.0

@onready var _update_timer: = $Timer as Timer


func _ready() -> void:
	text = ""
	
	_update_timer.timeout.connect(_on_timer_timeout)
	_update_timer.wait_time = update_frequency
	_update_timer.start()


func _on_timer_timeout() -> void:
	text = "FPS: %d" % Engine.get_frames_per_second()
