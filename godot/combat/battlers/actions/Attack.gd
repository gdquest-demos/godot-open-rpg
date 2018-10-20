extends CombatAction

func execute():
	if not (actor and target):
		return
	
