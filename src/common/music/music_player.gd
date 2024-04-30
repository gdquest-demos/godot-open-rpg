class_name MusicPlayer extends Node

@onready var _anim: = $AnimationPlayer as AnimationPlayer
@onready var _track: = $AudioStreamPlayer as AudioStreamPlayer


func play(new_stream: AudioStream, time_in: = 0.0, time_out: = 0.0) -> void:
	if new_stream == _track.stream:
		return
	
	if is_playing():
		if is_equal_approx(time_out, 0.0):
			time_out = 0.005
		
		_anim.speed_scale = 1.0/time_out
		_anim.play("fade_out")
		await _anim.animation_finished
		
		_track.stop()
	
	_track.stream = new_stream
	if is_equal_approx(time_in, 0.0):
		time_in = 0.005
	
	_track.volume_db = -50.0
	_track.play()
	_anim.speed_scale = 1.0/time_in
	_anim.play("fade_in")
	await _anim.animation_finished
	
	_anim.speed_scale = 1.0


func stop(time_out: = 0.0) -> void:
	if is_equal_approx(time_out, 0.0):
		time_out = 0.005
	
	_anim.speed_scale = 1.0/time_out
	_anim.play("fade_out")
	await _anim.animation_finished
	
	_track.stop()
	_track.stream = null


func is_playing() -> bool:
	return _track.playing


func get_playing_track() -> AudioStream:
	return _track.stream
