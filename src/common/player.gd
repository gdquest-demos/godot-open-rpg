## An autoload that provides easy access to the player's state, including both Combat and Field
## details.
## Reference to the player's party, inventory, and currently active character are found here.
## Additionally, game-wide player based signals are emitted from here.
extends Node

## Emitted whenever the player's gamepiece changes.
signal gamepiece_changed

## Emitted when the player sets a movement path for their focused gamepiece.
## The destination is the last cell in the path.
@warning_ignore("unused_signal")
signal player_path_set(gamepiece: Gamepiece, destination_cell: Vector2i)

var camera: Camera2D

## The gamepeice that the player is currently controlling. This is a read-only property.
var gamepiece: Gamepiece = null:
	set(value):
		if value != gamepiece:
			gamepiece = value
			
			if camera != null:
				camera.queue_free()
				camera = null
			
			if gamepiece != null:
				camera = Camera2D.new()
				gamepiece.animation.add_child(camera)
				camera.make_current()
			
			gamepiece_changed.emit()
