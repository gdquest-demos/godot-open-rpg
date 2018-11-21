extends Node2D
class_name Party

# amount of characters that should be in combat
# you should be able to define more than this that are
# in the party, just not active
const PARTY_SIZE = 3

func active_members():
	"""
	Fetch the first children who fill the party size
	"""
	var active = []
	var available = unlocked()
	for i in range(min(len(available), PARTY_SIZE)):
		active.append(available[i])
	return active
	
func unlocked() -> Array:
	"""
	Get all characters in the game that can be in your party
	that you have unlocked
	"""
	var has_unlocked = []
	for member in get_children():
		if member.visible:
			has_unlocked.append(member)
	return has_unlocked

func update_members(battlers : Array):
	"""
	Update's characters stats from their battlers
	after combat is complete
	"""
	for battler in battlers:
		var character_name = battler.name
		var stats = battler.stats as CharacterStats
		find_node(character_name, false).update_stats(stats)
