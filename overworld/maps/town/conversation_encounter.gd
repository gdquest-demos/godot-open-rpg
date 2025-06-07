@tool

extends Interaction

@export var pre_combat_timeline: DialogicTimeline
@export var victory_timeline: DialogicTimeline
@export var loss_timeline: DialogicTimeline

@export var combat_arena: PackedScene


func _execute() -> void:
	Dialogic.start_timeline(pre_combat_timeline)
	
	# Wait for the timeline to finish before beginning combat.
	await Dialogic.timeline_ended
	
	# Let other systems know that a combat has been triggered and then wait for its outcome.
	FieldEvents.combat_triggered.emit(combat_arena)
	
	var did_player_win: bool = await CombatEvents.combat_finished
	
	# The combat ends with a covered screen, and so we fix that here.
	Transition.clear.call_deferred(0.2)
	await Transition.finished
	
	# We want to run post-combat events. In some cases, this may not involve much, such as playing a
	# game-over screen or removing an AI combat-starting gamepiece from the field.
	# In some cases, however, we'll want a dialogue to play or some creative event to occur if, for
	# example, the player lost a difficult but non-essential battle.
	if did_player_win:
		Dialogic.start_timeline(victory_timeline)
	
	else:
		Dialogic.start_timeline(loss_timeline)
	
	await Dialogic.timeline_ended
