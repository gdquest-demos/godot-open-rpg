extends BattlerAI

const DEFAULT_CHANCE = 0.75


func choose_action(actor: Battler, battlers: Array = []):
	# For now, we just choose the first action on a battler
	# we use yield even though determining an action is instantaneous
	# because the combat arena expects this to be an async function
	yield(get_tree(), "idle_frame")
	return actor.actions.get_child(0)


func choose_target(actor: Battler, action: CombatAction, battlers: Array = []):
	# Chooses a target to perform an action on
	yield(get_tree(), "idle_frame")
	var this_chance = randi() % 100
	var target_min_health = battlers[randi() % len(battlers)]

	if this_chance > DEFAULT_CHANCE:
		return [target_min_health]

	var min_health = target_min_health.stats.health
	for target in battlers:
		# don't attack battlers on your team
		if actor.party_member == target.party_member:
			continue

		if target.stats.health < min_health:
			target_min_health = target

	return [target_min_health]
