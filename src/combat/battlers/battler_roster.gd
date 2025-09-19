class_name BattlerRoster extends RefCounted

var get_nodes_in_group: Callable


func _init(tree_ref: SceneTree) -> void:
	get_nodes_in_group = tree_ref.get_nodes_in_group


func get_battlers() -> Array[Battler]:
	var battler_list: Array[Battler] = []
	battler_list.assign(get_nodes_in_group.call(Battler.GROUP))
	return battler_list


func get_player_battlers() -> Array[Battler]:
	return get_battlers().filter(
		func _filter_players(battler: Battler):
			return battler.actor != null and battler.actor.is_player
	)


func get_enemy_battlers() -> Array[Battler]:
	return get_battlers().filter(
		func _filter_enemies(battler: Battler):
			return battler.actor != null and not battler.actor.is_player
	)


func are_battlers_defeated(battlers: Array[Battler]) -> bool:
	for battler in battlers:
		if battler.actor.is_active:
			return false
	
	return true
