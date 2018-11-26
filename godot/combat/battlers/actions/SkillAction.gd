extends CombatAction

func _ready() -> void:
	name = skill_to_use.skill_name
	randomize()

func execute():
	assert(initialized)
	if actor.party_member:
		print("TODO: SKILL -> if skill can target all enemies this command should be changed to SelectAllCommand")
		var target = yield(select_target_routine(), "completed")
		if target == null:
			return false
	yield(move_to_target_routine(), "completed")
	yield(use_skill_routine(), "completed")
	yield(return_to_start_position_routine(), "completed")
	return true
