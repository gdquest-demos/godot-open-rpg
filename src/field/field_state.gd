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
			var cell = Player.cell
			var vts = var_to_str(cell)
			var stv = str_to_var(vts)
			print("Combat occured at cell: %s. var_to_str: %s, str_to_var: %s" % [cell, vts, stv])
			
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
	
	_restore_changes()
	
	if opening_cutscene:
		opening_cutscene.run.call_deferred()
	
	else:
		await Transition.clear(fade_in_time)


# Setup the pieces on the Gameboard. This means instantiating the player and adjusting any
# existing gamepieces that may have moved.
# Eventually, this will be an automatic process, but for this iteration of the demo we'll do manual
# checks on the GPs that we know are persistent.
func _restore_changes() -> void:
	# Check to see if the player has retrieved the key yet.
	if Dialogic.VAR.get_variable("Town.KeyPickedUp") == true:
		var key: = $Map/Town/Ground/Gamepieces/KeyPickup
		key.queue_free()
		
		var trees: = $Map/Town/Ground/Gamepieces/StrangeTreeInteraction
		trees.queue_free()
	
	# Check to see if the ghost roaming encounter has been defeated.
	if Dialogic.VAR.Town.GhostDefeated == true:
		$Map/Town/Ground/Gamepieces/RoamingEncounter.queue_free()
	
	# Finally, place the adoring fan either at his position blocking the player or hiding in the
	# corner, depending on whether or not the player has spoken to him.
	var fan_gp: Gamepiece = $Map/Town/Ground/Gamepieces/AdoringFan
	var fan_location: String = Dialogic.VAR.get_variable("Town.FanCell")
	if fan_location.is_empty():
		print("Set fan location!")
		var cell: = Gameboard.pixel_to_cell(fan_gp.position)
		Dialogic.VAR.set_variable("Town.FanCell", var_to_str(cell))
		print(Dialogic.VAR.get_variable("Town.FanCell"))
	
	else:
		print("Know fan's location!")
		var cell = str_to_var(fan_location)
		if cell is Vector2i:
			print("Cell is ", cell)
			GamepieceRegistry.move_gamepiece(fan_gp, cell)
			fan_gp.position = Gameboard.cell_to_pixel(cell)


# Write any data from the overworld map that will need to be 
# Eventually, this will be an automatic process, but for this iteration of the demo we'll do manual
# caching of the following changes:
#	- Whether or not the ghost in the "RoamingEncounter" has been defeated
#	- Whether or not the strange tree area has been revealed or is still hidden.
#	- The location of the "AdoringFan", who moves out of the player's way after a conversation.
