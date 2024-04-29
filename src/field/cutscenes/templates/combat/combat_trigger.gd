@tool
class_name CombatTrigger extends Trigger

# The following signal is emitted as soon as the combat results are known. That is, the player has
# either lost and their battlers are now free OR the player has won and the combat results screen
# has already been closed.
# The trigger responds to this signal by running a screen transition.
signal _combat_resolved

@export var combat_arena: PackedScene

# An internal flag that tracks the outcome of a given combat instance. It is reset every time this
# trigger is run.
var _is_victory: = false


func _execute() -> void:
	# Cover the screen.
	await Transition.cover(0.2)
	
	# The screen is black, so let all systems know that it's time to setup the combat scene.
	CombatEvents.combat_initiated.emit(combat_arena)
	
	# The trigger wants to know if the player wins or loses combat, so we'll listen in for win/lose
	# signals. We only want the trigger to know about THIS combat, so we need to track the method
	# reference in order to disconnect it, since the callback will not be called on a loss.
	_is_victory = false
	CombatEvents.combat_won.connect(_on_combat_won)
	CombatEvents.combat_lost.connect(_on_combat_lost)
	
	# Before starting combat itself, reveal the screen again.
	# The Transition.clear() call is deferred since it follows on the heels of cover(), and needs a
	# frame to allow everything else to respond to Transition.finished.
	Transition.clear.call_deferred(0.2)
	await Transition.finished
	
	# Wait for combat to wrap up before continuing the trigger.
	await self._combat_resolved
	
	# Combat is finished, so we want to cover the screen again before re-starting the field scene.
	CombatEvents.combat_won.disconnect(_on_combat_won)
	CombatEvents.combat_lost.disconnect(_on_combat_lost)
	
	# Cover the screen again, transitioning away from the combat game state.
	await Transition.cover(0.2)
	
	# Now that the screen has been covered, let other systems know that the combat is over. This
	# will free up the combat arena, un-hide the field state, etc.
	# The Transition.clear() call is deferred since it follows on the heels of cover(), and needs a
	# frame to allow everything else to respond to Transition.finished.
	CombatEvents.combat_finished.emit()
	Transition.clear.call_deferred(0.2)
	await Transition.finished
	
	# We want to run post-combat events. In some cases, this may not involve much, such as playing a
	# game-over screen or removing an AI combat-starting gamepiece from the field.
	# In some cases, however, we'll want a dialogue to play or some creative event to occur if, for
	# example, the player lost a difficult but non-essential battle.
	if _is_victory:
		await _run_victory_cutscene()
	
	else:
		await _run_loss_cutscene() 


# The following method is called once the player has won combat and dismissed the results screen.
# This hands control back to this trigger, which may then cover the screen and transition back to
# the field.
# Note that this is not merely a lambda since we only want this callback to respond to the combat of
# this particular trigger and, therefore, must be reconnected/disconnected as the trigger is run.
func _on_combat_won() -> void:
	_is_victory = true
	_combat_resolved.emit()


# The following method is called once the player has lost combat and animations have finished.
# This hands control back to this trigger, which may then cover the screen and transition back to
# the field or the gameover screen.
# Note that this is not merely a lambda since we only want this callback to respond to the combat of
# this particular trigger and, therefore, must be reconnected/disconnected as the trigger is run.
func _on_combat_lost() -> void:
	_combat_resolved.emit()


## The following method may be overwridden to allow for custom behaviour following a combat victory.
## Examples include adding an item to the player's inventory, running a dialogue, removing an enemy
## [Gamepiece], etc.
func _run_victory_cutscene() -> void:
	await get_tree().process_frame


## The following method may be overwridden to allow for custom behaviour following a combat loss.
## In most cases this may result in a gameover, but in others it may run a cutscene, change some
## sort of event flag, etc.
func _run_loss_cutscene() -> void:
	await get_tree().process_frame
