# Opens up a secret path once the 'Strange Tree' has been interacted with twice.
extends Interaction

var _conversation: = preload("res://data/maps/town/strange_tree.dtl")

@onready var _anim: = $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	super._ready()
	
	# We want to open the secret path once the player has performed a specific action.
	# The easiest method is to allow Dialogic to determine when this should happen. This could be
	# done via the EmitSignal event, the Call event, or, as we've opted to do here, an in-dialogue
	# signal.
	# Note that the signal argument must match exactly for the lambda to play.
	Dialogic.text_signal.connect(
		func(argument: String):
			if argument == "clear_secret_path":
				# Clearing the secret path is controlled exclusively by the animation player.
				# Once the animation has finished, pathfinders will need to be updated via the
				# terrain_chagned signal below.
				_anim.play("disappear")
				_anim.animation_finished.connect(
					func(_anim_name): FieldEvents.terrain_changed.emit(),
					CONNECT_ONE_SHOT
				)
	)


func interact() -> void:
	Dialogic.start_timeline(_conversation)
