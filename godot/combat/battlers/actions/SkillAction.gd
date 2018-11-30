extends CombatAction

func _ready() -> void:
	name = skill_to_use.skill_name
	randomize()

func execute(targets):
	assert(initialized)
	if actor.party_member and not targets:
		return false
	
	# Use skill on all targets
	if skill_to_use.success_chance == 1.0:
		actor.use_skill(targets, skill_to_use)
	else:
		randomize()
		if rand_range(0, 1.0) < skill_to_use.success_chance:
			actor.use_skill(targets, skill_to_use)
	yield(actor.get_tree().create_timer(1.0), "timeout")

	yield(return_to_start_position(), "completed")
	return true
