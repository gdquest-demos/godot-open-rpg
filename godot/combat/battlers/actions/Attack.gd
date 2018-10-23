extends CombatAction

func execute(actor : Battler, target : Battler):
	actor.attack(target)
	emit_signal("execute_finished")
