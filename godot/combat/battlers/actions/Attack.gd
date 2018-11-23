extends CombatAction

func execute():
	assert(initialized)
	print("TODO: ATTACK -> at some point we should define the attack commands based on the equiped items\n" +
		  "ie: if you have a bow you should not move to the target!")
	if actor.party_member:
		yield(select_target_routine(), "completed")
	yield(move_to_target_routine(), "completed")
	yield(attack_routine(), "completed")
	yield(return_to_start_position_routine(), "completed")
