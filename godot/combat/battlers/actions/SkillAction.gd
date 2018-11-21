extends CombatAction

var skill_to_use : Skill

func _ready() -> void:
	name = skill_to_use.skill_name
	randomize()

func execute(actor : Battler, target : Battler) -> void:
	if skill_to_use.success_chance == 1.0:
		actor.use_skill(target, skill_to_use)
	else:
		randomize()
		if rand_range(0, 1.0) < skill_to_use.success_chance:
			actor.use_skill(target, skill_to_use)
	emit_signal("execute_finished")
