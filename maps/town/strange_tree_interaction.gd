# Opens up a secret path once the 'Strange Tree' has been interacted with twice.
extends InteractionTemplateConversation

@onready var _anim: = $AnimationPlayer as AnimationPlayer
@onready var _popup: = $InteractionPopup as InteractionPopup


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
				# Once the secret path is cleared, we'll want to deactivate the interaction to
				# prevent the user from running it again.
				is_active = false
				_popup.hide_and_free()
				
				# Clearing the secret path is controlled exclusively by the animation player.
				# Once the animation has finished, pathfinders will need to be updated via the
				# terrain_chagned signal below.
				_anim.play("disappear")
				_anim.animation_finished.connect(
					func(_anim_name): 
						FieldEvents.terrain_changed.emit(),
					CONNECT_ONE_SHOT
				)
	)
