class_name MusicPlayer
extends Node

signal volume_changed

var volume: = Audio.VOLUME_FULL:
	set(value):
		volume = value
		_current_track.volume_db = volume

var _stopped_position: = 0.0

var _volume_tween: Tween = null

@onready var _current_track: = $Track1 as AudioStreamPlayer


func play(new_stream: AudioStream = null) -> void:
	if _current_track.playing: 
		# Don't restart the music if we're already playing new_stream.
		if _current_track.stream == new_stream:
			return
		
		_current_track.stop()
	
	if new_stream != _current_track.stream:
		_current_track.stream = new_stream
		_stopped_position = 0.0
	
	_current_track.play(_stopped_position)


func stop() -> void:
	if _current_track.playing:
		_stopped_position = _current_track.get_playback_position()
		_current_track.stop()


func tween_volume(target_volume: float, duration: float) -> void:
	if duration < 0:
		duration = 0
	
	if _volume_tween:
		_volume_tween.kill()
	_volume_tween = create_tween()
	
	_volume_tween.tween_property(self, "volume", target_volume, duration)
	_volume_tween.tween_callback(func(): volume_changed.emit())


func is_playing() -> bool:
	return _current_track.playing
