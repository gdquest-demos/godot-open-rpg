## Wrapping [AudioStreamPlayer], the MusicPlayer provides common functions needed to easily play
## music or an ambience track.
class_name MusicPlayer
extends Node

## Emitted whenever [member volume] changes.
signal volume_changed

## The volume at which the music is played.
## May be set directly or tweened smoothly via [function tween_volume].
var volume: = Audio.VOLUME_FULL:
	set(value):
		volume = value
		_current_track.volume_db = volume

# Keep track of the position at which the music was stopped. This is used when resuming a stopped
# track.
var _stopped_position: = 0.0

var _volume_tween: Tween = null

@onready var _current_track: = $Track1 as AudioStreamPlayer


## Begin playing a new track or resume the current stopped track.
## [br][br]If [code]new_stream[/code] is provided and does not match the currently playing track, it
## will be played directly from the beginning. It may be desirable to fade out the old track first
## via [function tween_volume].
## [br][br]Otherwise, resume the current track from the last position if it is stopped.
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


## Stop the playing track, usually after fading the volume via [function tween_volme].
## The track may be resumed from its stopped position by calling [function play] without a passing 
## a new audio stream.
func stop() -> void:
	if _current_track.playing:
		_stopped_position = _current_track.get_playback_position()
		_current_track.stop()


## Change volume smoothly over a specified [code]duration[/code].
func tween_volume(target_volume: float, duration: float) -> void:
	if duration < 0:
		duration = 0
	
	if _volume_tween:
		_volume_tween.kill()
	_volume_tween = create_tween()
	
	_volume_tween.tween_property(self, "volume", target_volume, duration)
	_volume_tween.tween_callback(func(): volume_changed.emit())


## Returns [code]true[/code] if an audio stream is currently playing.
func is_playing() -> bool:
	return _current_track.playing
