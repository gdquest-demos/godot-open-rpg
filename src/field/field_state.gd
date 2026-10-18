extends GameState

@export_group("Screen Fade")

## The cutscene that will play on starting a new game.
#@export var opening_cutscene: Cutscene

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
			# Clear the autoloads tracking the Gameboard and Gamepiece states. This will be re-
			# created whenever the Overworld game state is entered again.
			Gameboard.pathfinder.clear()
			GamepieceRegistry.clear()
			
			# Save the current inventory to disk.
			Inventory.restore().save()
			
			await Transition.cover(combat_fade_out_time)
			
			Combat.current_arena = arena
			transition_executed.emit(Game.States.COMBAT)
	)


# Initialize the overworld state, setting up the map according to current gameplay variables (see
# Dialogic's VAR system) and any cutscene that is queued to run.
func start() -> void:
	Player.create_gamepiece($Map/Town/Ground/Gamepieces)
	
	_restore_changes()
	
	# Whenever transitioning to the field game state the developer may want a cutscene to run.
	# Examples include an introduction to a new area that hasn't been visited before, a special
	# event that occurs after a boss combat, or a flashback that occurs when travelling.
	# Currently, we assume that the stored value is one of two things:
	#	- a path to a Cutscene that exists in the newly loaded field map.
	#	- the file path to a Cutscene file, useful for common things that happen after a combat
	#		(e.g. game over when losing combat).
	var path_to_cutscene: String = Dialogic.VAR.get_variable("QueuedCutscene", "")
	if has_node(path_to_cutscene):
		var cutscene: = get_node(path_to_cutscene) as Cutscene
		if cutscene != null:
			cutscene.run.call_deferred()
	
	elif ResourceLoader.exists(path_to_cutscene):
		var packed_scene: = load(path_to_cutscene) as PackedScene
		var new_cutscene = packed_scene.instantiate()
		if new_cutscene is Cutscene:
			add_child(new_cutscene)
			await new_cutscene.run.call_deferred()
			new_cutscene.queue_free()
	
	else:
		await Transition.clear(fade_in_time)


# Setup the pieces on the Gameboard. This means instantiating the player and adjusting any
# existing gamepieces that may have moved.
# Eventually, this will be an automatic process, but for this iteration of the demo we'll do manual
# checks on the GPs that we know are persistent.
func _restore_changes() -> void:
	# Check to see if the player has retrieved the key yet.
	# If they have, check to see if the door is unlocked.
	if Dialogic.VAR.get_variable("Town.KeyPickedUp") > 0:
		var key: = $Map/Town/Ground/Gamepieces/KeyPickup
		key.queue_free()
		
		if Dialogic.VAR.get_variable("Town.KeyPickedUp") > 1:
			var door = $Map/Town/Ground/Gamepieces/Door
			door.is_locked = false
		
		var trees: = $Map/Town/Ground/Gamepieces/StrangeTreeInteraction
		trees.queue_free()
	
	# Check on how the player has progressed with the want pedastal, and set values accordingly.
	$Map/House/Gamepieces/PedestalPuzzle/GreenPedestal.current_item_id \
		= Dialogic.VAR.get_variable("Pedestal.Green", -1)
	$Map/House/Gamepieces/PedestalPuzzle/BluePedestal.current_item_id \
		= Dialogic.VAR.get_variable("Pedestal.Blue", -1)
	$Map/House/Gamepieces/PedestalPuzzle/RedPedestal.current_item_id \
		= Dialogic.VAR.get_variable("Pedestal.Red", -1)
	
	# Check to see if the ghost roaming encounter has been defeated.
	if Dialogic.VAR.Town.GhostDefeated == true:
		$Map/Town/Ground/Gamepieces/RoamingEncounter.queue_free()
	
	# Finally, place the adoring fan either at his position blocking the player or hiding in the
	# corner, depending on whether or not the player has spoken to him.
	var fan_gp: Gamepiece = $Map/Town/Ground/Gamepieces/AdoringFan
	var fan_location: String = Dialogic.VAR.get_variable("Town.FanCell")
	if fan_location.is_empty():
		var cell: = Gameboard.pixel_to_cell(fan_gp.position)
		Dialogic.VAR.set_variable("Town.FanCell", var_to_str(cell))
	
	else:
		var cell = str_to_var(fan_location)
		if cell is Vector2i:
			GamepieceRegistry.move_gamepiece(fan_gp, cell)
			fan_gp.position = Gameboard.cell_to_pixel(cell)


# Write any data from the overworld map that will need to be 
# Eventually, this will be an automatic process, but for this iteration of the demo we'll do manual
# caching of the following changes:
#	- Whether or not the ghost in the "RoamingEncounter" has been defeated
#	- Whether or not the strange tree area has been revealed or is still hidden.
#	- The location of the "AdoringFan", who moves out of the player's way after a conversation.
