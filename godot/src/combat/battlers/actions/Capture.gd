extends CombatAction

onready var drops := $Drops

func execute(targets):
	assert(initialized)
	if actor.party_member and not targets:
		return false

	for target in targets:
		yield(actor.skin.move_to(target), "completed")
		if target.stats.health < 100:
			var hit = Hit.new(1000)
			#var combat_arena = target.get_parent().get_parent()
			#combat_arena.capture_reward()
			target.drops.get_children().push_back({'item': 'Slime.tres', 'amount': '1'})
			target.take_damage(hit)
		yield(actor.get_tree().create_timer(1.0), "timeout")
		yield(return_to_start_position(), "completed")
	return true
