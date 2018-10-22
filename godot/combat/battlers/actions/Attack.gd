extends CombatAction

func execute(actor : Battler, target : Battler):
	return actor.attack(target)
