extends CombatAction

class_name SkillAction

var skill : Skill = null

func _ready() -> void:
	name = skill.name
	icon = skill.icon
	randomize()

func execute(targets):
	assert(initialized)
	if actor.party_member and not targets:
		return false
	
	# Use skill on all targets
	if skill.success_chance == 1.0:
		actor.use_skill(targets, skill)
	else:
		randomize()
		if rand_range(0, 1.0) < skill.success_chance:
			actor.use_skill(targets, skill)
		else:
			actor.miss_skill(skill)
	yield(actor.get_tree().create_timer(1.0), "timeout")

	yield(return_to_start_position(), "completed")
	return true
