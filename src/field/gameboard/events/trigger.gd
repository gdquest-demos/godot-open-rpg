## A field map-based [Event] that is triggered by colliding with a [Gamepiece].
class_name Trigger
extends Event

@export var halt_movement: = false

var _gamepiece: Gamepiece = null


func _ready() -> void:
	super._ready()
	area_entered.connect(_on_area_entered)


func _execute() -> void:
	assert(_gamepiece, "Trigger '%s' executed without valid gamepiece!" % name)
	
	for gp in get_tree().get_nodes_in_group(Groups.GAMEPIECES):
		if gp is Gamepiece:
			gp.can_travel = false
	
	$Timer.start()
	await $Timer.timeout
	
	music_player.tween_volume(-20.0, 3.5)
	$AnimationPlayer.play("hide")
	await music_player.volume_changed
	
	$Timer.start()
	await $Timer.timeout
	
	music_player.tween_volume(0.0, 1.5)
	await music_player.volume_changed


# Check to see if a gamepiece has entered the trigger.
func _on_area_entered(area: Area2D) -> void:
	# By default, triggers are interested exclusively in gamepieces.
	var gamepiece: = area.owner as Gamepiece
	
	if gamepiece:
		_gamepiece = gamepiece
		if gamepiece.is_travelling():
			gamepiece.arriving.connect(_on_gamepiece_arriving.bind(gamepiece))
		
		else:
			_execute()


# A moving gamepiece will arrive at the trigger cell this frame.
func _on_gamepiece_arriving(_remaining_movement: float, gamepiece: Gamepiece) -> void:
	gamepiece.arriving.disconnect(_on_gamepiece_arriving)
	
	_execute()
