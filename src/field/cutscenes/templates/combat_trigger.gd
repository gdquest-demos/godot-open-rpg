@tool
class_name CombatTrigger extends Trigger

@export var combat_arena: PackedScene


func _execute() -> void:
	print("FIGHT!")
	CombatEvents.combat_initiated.emit(combat_arena)
