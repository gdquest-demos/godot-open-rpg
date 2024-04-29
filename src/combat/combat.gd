extends CanvasLayer

var _active_arena: CombatArena = null

@onready var _combat_containter: = $CenterContainer as CenterContainer


func _ready() -> void:
	CombatEvents.combat_initiated.connect(_on_combat_initiated)
	CombatEvents.combat_finished.connect(_on_combat_finished)


func _on_combat_initiated(arena: PackedScene) -> void:
	# Don't start a new combat if one is currently ongoing.
	if _active_arena:
		return
	
	# Try to setup the combat arena (which comes with AI battlers, etc.). 
	var new_arena: = arena.instantiate()
	assert(new_arena is CombatArena,
		"Failed to initiate combat. Provided 'arena' arugment is not a CombatArena.")
	
	_active_arena = new_arena
	_combat_containter.add_child(_active_arena)


func _on_combat_finished() -> void:
	if not _active_arena:
		return
	
	_active_arena.queue_free()
	_active_arena = null
