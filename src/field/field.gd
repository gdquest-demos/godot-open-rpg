extends GameState

@export_group("On-open settings")
## The cutscene that will play on starting a new game.
@export var opening_cutscene: Cutscene

## If there is no cutscene, the screen will just fade in before giving the player control.
## Defines how the length of the fade in animation.
@export var fade_in_time: = 0.3

@export_group("Player")
## A PlayerController that will be dynamically assigned to whichever Gamepiece the player currently
## controls.
@export var player_controller: PackedScene

## The first gamepiece that the player will control. This may be null and assigned via an
## introductory cutscene instead.
@export var player_default_gamepiece: Gamepiece


func _ready() -> void:
	randomize()
	
	# Assign proper controllers to player gamepieces whenever they change.
	#Player.gamepiece_changed.connect(
		#func _on_player_gp_changed() -> void:
			#print("Player gp changed")
			#var new_gp: = Player.gamepiece
			##Camera.gamepiece = new_gp
	#
			## Free up any lingering controller(s).
			#for controller in get_tree().get_nodes_in_group(PlayerController.GROUP):
				#controller.queue_free()
			#
			#if new_gp:
				#var new_controller = player_controller.instantiate()
				#assert(new_controller is PlayerController, "The Field game state requires a valid
					 #PlayerController set in the editor!")
				#
				#new_gp.add_child(new_controller)
				#new_controller.is_active = true
	#)
	Player.create_gamepiece($Map/Town/Ground/Gamepieces)
	#Player.gamepiece = player_default_gamepiece
	
	
	# The field state must pause/unpause with combat accordingly.
	# Note that pausing/unpausing input is already wrapped up in triggers, which are what will
	# initiate combat.
	#CombatEvents.combat_initiated.connect(func(): hide())
	#CombatEvents.combat_finished.connect(func(_is_victory): show())


func start() -> void:
	if opening_cutscene:
		opening_cutscene.run.call_deferred()
	
	else:
		await Transition.clear(fade_in_time)
