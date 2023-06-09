## A field map-based [Event] that is triggered by colliding with a [Gamepiece].
##
## In the event that the triggering gamepiece is travelling, the trigger will wait for the gamepiece
## to arrive before calling [method run].
class_name Trigger
extends Event

var _gamepiece: Gamepiece = null


func _ready() -> void:
	super._ready()
	area_entered.connect(_on_area_entered)


# Check to see if a gamepiece has entered the trigger. Moving gamepieces will finish their travel
# path before the even is run, otherwise the event is run immediately.
func _on_area_entered(area: Area2D) -> void:
	# By default, triggers are interested exclusively in gamepieces.
	var gamepiece: = area.owner as Gamepiece
	
	if gamepiece:
		_gamepiece = gamepiece
		if gamepiece.is_travelling():
			gamepiece.arriving.connect(func(_remaining_time): run(), CONNECT_ONE_SHOT)
		
		else:
			run()
