extends GameState

@export_group("Transition")
## The cutscene that will play on starting a new game.
@export var opening_cutscene: Cutscene

## If there is no cutscene, the screen will just fade in before giving the player control.
## Defines how the length of the fade in animation.
@export var fade_in_time: = 0.3

## The time taken to fade the scene before initiating combat.
@export var combat_fade_out_time: = 0.2


func _ready() -> void:
	# DEBUG: the following code allows using this scene as the main entry point.
	# The is especially useful for quickly testing out new areas. Load it into the scene and run
	# the overworld state directly.
	# To set the player's initial cell, modify Player.cell in the Player autoload.
	# Note that the player cannot change game states unless the entry point is Main.tscn. To test a
	# combat arena consider running Combat.tscn directly.
	if get_parent() == get_tree().root:
		start.call_deferred()
	
	FieldEvents.combat_triggered.connect(
		func _on_combat_triggered(arena: PackedScene) -> void:
			await Transition.cover(combat_fade_out_time)
			
			Combat.current_arena = arena
			transition_executed.emit(Game.States.COMBAT)
	)
	
	
	# The field state must pause/unpause with combat accordingly.
	# Note that pausing/unpausing input is already wrapped up in triggers, which are what will
	# initiate combat.
	#CombatEvents.combat_initiated.connect(func(): hide())
	#CombatEvents.combat_finished.connect(func(_is_victory): show())


func start() -> void:
	Player.create_gamepiece($Map/Town/Ground/Gamepieces)
	if opening_cutscene:
		opening_cutscene.run.call_deferred()
	
	else:
		await Transition.clear(fade_in_time)
