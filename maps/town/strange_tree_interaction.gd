# Opens up a secret path once the 'Strange Tree' has been interacted with twice.
extends InteractionTemplateConversation

@onready var _anim: = $AnimationPlayer as AnimationPlayer
@onready var _popup: = $InteractionPopup as InteractionPopup


func _execute() -> void:
	# We want to open the secret path once the player has performed a specific action.
	# The easiest method is to allow Dialogic to determine when this should happen. This could be
	# done via the EmitSignal event, the Call event, or, as we've opted to do here, an in-dialogue
	# signal.
	# Note that this connection only occurs when this particular dialogue occurs. Since this
	# interaction only really happens once, we don't care what signal argument is passed, only that
	# the signal itself is emitted.
	await super._execute()


func _on_dialogic_signal_event(_argument: String) -> void:
	# Once the secret path is cleared, we'll want to deactivate the interaction to
	# prevent the user from running it again.
	is_active = false
	_popup.hide_and_free()
	
	# Clearing the secret path is controlled exclusively by the animation player.
	# Once the animation has finished, pathfinders will need to be updated via the
	# terrain_chagned signal below.
	_anim.play("disappear")
	await _anim.animation_finished
	
	FieldEvents.terrain_changed.emit()
