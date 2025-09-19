@icon("icon_turn_queue.png")
class_name CombatTurnQueue extends Node

## Emitted whenever the combat logic has finished, including all animation details.
signal finished(has_player_won: bool)

## A list of the combat participants, in [BattlerList] form. This object is created by the turn
## queue from children [Battler]s and then made available to other combat systems.
var battler_roster: BattlerRoster

## Tracks which combat round is currently being played. Every round, all active Actors will get a
## turn to act.
var round_count = 1:
	set(value):
		round_count = value
		print("\nBegin turn %d" % round_count)


func _ready() -> void:
	battler_roster = BattlerRoster.new(get_tree())


func start() -> void:
	round_count = 1
	_next_turn.call_deferred()


func get_actors() -> Array[CombatActor]:
	var actor_list: Array[CombatActor] = []
	actor_list.assign(get_tree().get_nodes_in_group(CombatActor.GROUP))
	return actor_list


func _next_turn() -> void:
	# Check for battle end conditions, that one side has been downed.
	if battler_roster.are_battlers_defeated(battler_roster.get_player_battlers()):
		finished.emit.call_deferred(false)
		return
	elif battler_roster.are_battlers_defeated(battler_roster.get_enemy_battlers()):
		finished.emit.call_deferred(true)
		return

		# Check for an active actor. If there are none, it may be that the turn has finished and all
		# actors can have their has_acted_this_turn flag reset.
	var next_actor: = _get_next_actor()
	if not next_actor:
		_reset_has_acted_flag()

		# If there is no actor now, there is a situation where the only remaining Battler's don't
		# have assigned actors. In other words, all controlled actors (player included) are downed.
		# In this case, register as a player loss.
		next_actor = _get_next_actor()
		if not next_actor:
			finished.emit(false)
			return

		round_count += 1

	# Connect to the actor's turn_finished signal. The actor is guaranteed to emit the signal,
	# even if it will be freed at the end of this frame.
	# However, we'll call_defer the next turn, since the current actor may have been downed on its
	# turn and we need a frame to process the change.
	next_actor.turn_finished.connect(
		(func _on_actor_turn_finished(actor: CombatActor) -> void:
				actor.has_acted_this_turn = true
				_next_turn.call_deferred()).bind(next_actor),
			CONNECT_ONE_SHOT
	)
	next_actor.start_turn()


func _get_next_actor() -> CombatActor:
	var actors: = get_actors()
	actors.sort_custom(CombatActor.sort)

	var ready_to_act_actors: = actors.filter(
		func _filter_actors(actor: Battler) -> bool:
			return actor.is_active and not actor.has_acted_this_turn
	)
	if ready_to_act_actors.is_empty():
		return null

	return ready_to_act_actors.front()


func _reset_has_acted_flag() -> void:
	for actor in get_actors():
		actor.has_acted_this_round = false


func _to_string() -> String:
	var actors: = get_actors()
	actors.sort_custom(CombatActor.sort)

	var msg: = "\n%s (CombatTurnQueue) - round %d" % [name, round_count]
	for actor in actors:
		msg += "\n\t" + actor.to_string()
	return msg
