extends CombatAction

func execute(actor : Battler, target : Battler) -> void:
	actor.attack(target)
	emit_signal("execute_finished")
