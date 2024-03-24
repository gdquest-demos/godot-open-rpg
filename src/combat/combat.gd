extends CanvasLayer

var _active_arena: CombatArena = null


func _on_combat_initiated(arena: PackedScene) -> void:
	# Don't start a new combat if one is currently ongoing.
	if _active_arena:
		return
	
	# Try to setup the combat arena (which comes with AI battlers, etc.). 
	var new_arena: = arena.instantiate()
	assert(new_arena is CombatArena,
		"Failed to initiate combat. Provided 'arena' arugment is not a CombatArena.")
	add_child(new_arena)
