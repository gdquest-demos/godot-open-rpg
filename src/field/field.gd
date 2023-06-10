extends Node

## The physics layers which will be used to search for gamepiece objects.
## Please see the project properties for the specific physics layers. [b]All[/b] collision shapes
## matching the mask will be checked regardless of position in the scene tree.
@export_flags_2d_physics var gamepiece_mask: = 0

## Colliders matching the following mask will be used to determine which cells have [Interaction]s.
@export_flags_2d_physics var interaction_mask: = 0

## The physics layers which will be used to search for terrain obejcts.
@export_flags_2d_physics var terrain_mask: = 0

@export var focused_game_piece: Gamepiece = null:
	set = set_focused_game_piece

@onready var camera: = $Camera2D as Camera2D
@onready var cursor: = $Objects/PlayerCursor as FieldCursor
@onready var music: = $MusicPlayer as MusicPlayer


func _ready() -> void:
	randomize()
	
	# The field needs to setup all events. Events dynamically added to the scene tree will be picked
	# up by the following method...
	FieldEvents.event_ready.connect(_on_event_ready)
	
	# ... but existing events are already ready, so must now be setup seperately.
	for event in get_tree().get_nodes_in_group(Groups.EVENTS):
		_setup_event(event)
	
	music.play(load("res://assets/audio/music/Insect Factory LOOP.wav"))
	
	cursor.interaction_mask = interaction_mask
	
	place_camera_at_focused_game_piece.call_deferred()


func place_camera_at_focused_game_piece() -> void:
	camera.reset_smoothing()


func set_focused_game_piece(value: Gamepiece) -> void:
	if value == focused_game_piece:
		return
	
	if focused_game_piece:
		focused_game_piece.camera_anchor.remote_path = ""
	
	focused_game_piece = value
	
	if not is_inside_tree():
		await ready
	
	# Free up any lingering human controller(s).
	for controller in get_tree().get_nodes_in_group(Groups.PLAYER_CONTROLLERS):
		controller.queue_free()
	
	if focused_game_piece:
		var camera_path: = focused_game_piece.camera_anchor.get_path_to(camera)
		focused_game_piece.camera_anchor.remote_path = camera_path
		
		var new_controller = PlayerController.new()
		new_controller.gamepiece_mask = gamepiece_mask
		new_controller.interaction_mask = interaction_mask
		new_controller.terrain_mask = terrain_mask
		
		focused_game_piece.add_child(new_controller)
		new_controller.is_active = true


## Mute all field game state related audio channels.
## A fade time may be provided, which will allow the audio channels to fade out before being muted.
func mute(decrescendo_time: = -1.0) -> void:
	var volume_tween: = create_tween()
	var music_bus_idx: = AudioServer.get_bus_index("FieldMusic")
	var sfx_bus_idx: = AudioServer.get_bus_index("FieldSFX")
	var ui_bus_idx: = AudioServer.get_bus_index("FieldUI")
	
	if decrescendo_time > 0.0:
		volume_tween.tween_method(
			func(value: float) -> void:
				AudioServer.set_bus_volume_db(music_bus_idx, value)
				AudioServer.set_bus_volume_db(sfx_bus_idx, value)
				AudioServer.set_bus_volume_db(ui_bus_idx, value),
			Audio.VOLUME_FULL,
			Audio.VOLUME_MUTE,
			decrescendo_time)
	
	volume_tween.tween_callback(AudioServer.set_bus_mute.bind(music_bus_idx, true))
	volume_tween.parallel().tween_callback(AudioServer.set_bus_mute.bind(sfx_bus_idx, true))
	volume_tween.parallel().tween_callback(AudioServer.set_bus_mute.bind(ui_bus_idx, true))
	
	if decrescendo_time > 0.0:
		await volume_tween.finished
	
	else:
		await get_tree().process_frame


## Unute all field game state related audio channels.
## A 'rise' time may be provided, which will allow the audio channels to gain inensity until at full
## volume.
func unmute(crescendo_time: = -1.0) -> void:
	var volume_tween: = create_tween()
	var music_bus_idx: = AudioServer.get_bus_index("FieldMusic")
	var sfx_bus_idx: = AudioServer.get_bus_index("FieldSFX")
	var ui_bus_idx: = AudioServer.get_bus_index("FieldUI")
	
	volume_tween.tween_callback(AudioServer.set_bus_mute.bind(music_bus_idx, false))
	volume_tween.parallel().tween_callback(AudioServer.set_bus_mute.bind(sfx_bus_idx, false))
	volume_tween.parallel().tween_callback(AudioServer.set_bus_mute.bind(ui_bus_idx, false))
	
	if crescendo_time > 0.0:
		volume_tween.tween_method(
			func(value: float) -> void:
				AudioServer.set_bus_volume_db(music_bus_idx, value)
				AudioServer.set_bus_volume_db(sfx_bus_idx, value)
				AudioServer.set_bus_volume_db(ui_bus_idx, value),
			Audio.VOLUME_MUTE,
			Audio.VOLUME_FULL,
			crescendo_time)
		
		await volume_tween.finished
	
	else:
		await get_tree().process_frame


# Inject essential dependencies to events.
func _setup_event(event: Event) -> void:
	print("Setup event ", event.name)
	event.music_player = music
	
	if event is Interaction:
		event.highlighted.connect(cursor._find_interactables_under_cursor)
		event.unhighlighted.connect(cursor._find_interactables_under_cursor)


# Dynamic events need to be setup on their creation.
func _on_event_ready(event: Event) -> void:
	_setup_event(event)
