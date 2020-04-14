# Utility to represent a list of active, available, or finished quests
extends Node


func find(_quest: Quest) -> Quest:
	# Finds a quest by reference and returns it
	for quest in get_children():
		if quest.name == _quest.name:
			return quest
	return null


func get_quests() -> Array:
	return get_children()
