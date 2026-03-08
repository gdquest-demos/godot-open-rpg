## The BattlerRoster provides easy access to combat participants.
##
## The roster is a central means of accessing all the [Battler]s in a combat, providing utility
## methods to filter them for a number of criteria (player, enemy, is_alive, etc.).
##
## Note that Battlers must be a descendent (though not necessarily a direct child) of the roster
## to be included in combat.
@icon("icon_turn_queue.png")
class_name BattlerRoster extends Node


## Returns all Battlers existing in the current combat.
func get_battlers() -> Array[Battler]:
	var battler_list: Array[Battler] = []
	battler_list.assign(find_children("*", "Battler"))
	return battler_list


## Returns all existing player Battlers.
func get_player_battlers() -> Array[Battler]:
	return get_battlers().filter(
		func _filter_players(battler: Battler):
			return battler.is_player
	)


## Returns all existing Battlers that are opposed to the player.
func get_enemy_battlers() -> Array[Battler]:
	return get_battlers().filter(
		func _filter_enemies(battler: Battler):
			return not battler.is_player
	)


## Filter an array of Battlers to return only whose health points are currently greater than 0.
func find_live_battlers(battlers: Array[Battler]) -> Array[Battler]:
	return battlers.filter(func(battler: Battler): return battler.stats.health > 0)


## Filter an array of Battlers to find those who are active but do not yet have a cached action (see
## [member Battler.cached_action]).
func find_battlers_needing_actions(battlers: Array[Battler]) -> Array[Battler]:
	return battlers.filter(
		func _filter_actors(actor: Battler) -> bool:
			return actor.is_active and actor.cached_action == null
	)


## Filter an array of Battlers to find those who may take an action. That is, they are active (see
## [member Battler.is_active]) and have a cached action ready (see [member Battler.cached_action]).
func find_ready_to_act_battlers(battlers: Array[Battler]) -> Array[Battler]:
	return battlers.filter(
		func _filter_actors(actor: Battler) -> bool:
			return actor.is_active and actor.cached_action != null
	)


## Returns true if all the specified battlers are inactive.
func are_battlers_defeated(battlers: Array[Battler]) -> bool:
	for battler in battlers:
		if battler.is_active:
			return false
	
	return true


func _to_string() -> String:
	var battlers: = get_battlers()
	battlers.sort_custom(Battler.sort)

	#var msg: = "\n%s (CombatTurnQueue) - round %d" % [name, round_count]
	var msg: = "\n%s - BattlerRoster" % name
	for battler in battlers:
		msg += "\n\t" + battler.to_string()
	return msg
