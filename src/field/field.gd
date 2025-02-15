extends Node2D

const PLAYER_CONTROLLER: = preload("res://src/field/gamepieces/controllers/player_controller.tscn")

@export var opening_cutscene: Cutscene

@export var focused_game_piece: Gamepiece = null:
	set = set_focused_game_piece

@export var gameboard: Gameboard


func _ready() -> void:
	assert(gameboard)
	randomize()
	
	# The field state must pause/unpause with combat accordingly.
	# Note that pausing/unpausing input is already wrapped up in triggers, which are what will
	# initiate combat.
	CombatEvents.combat_initiated.connect(func(): hide())
	CombatEvents.combat_finished.connect(func(_is_victory): show())
	
	Camera.scale = scale
	Camera.gameboard = gameboard
	Camera.make_current()
	Camera.reset_position()
	
	if opening_cutscene:
		opening_cutscene.run.call_deferred()


func set_focused_game_piece(value: Gamepiece) -> void:
	if value == focused_game_piece:
		return

	focused_game_piece = value
	
	if not is_inside_tree():
		await ready
	
	Camera.gamepiece = focused_game_piece
	
	# Free up any lingering controller(s).
	for controller in get_tree().get_nodes_in_group(PlayerController.GROUP_NAME):
		controller.queue_free()
	
	if focused_game_piece:
		var new_controller = PLAYER_CONTROLLER.instantiate()
		
		focused_game_piece.add_child(new_controller)
		new_controller.is_active = true
