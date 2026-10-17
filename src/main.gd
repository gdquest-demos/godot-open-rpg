## The entry point for the application.
## Specifies and manages game "states", allows transitions to whichever is active at a given moment.
class_name Game extends Node2D

## Discrete, relatively simple, transitions easily mapped out
enum States { MAIN_MENU, OVERWORLD, COMBAT }

# The entry point for the app.
@export var initial_state: States = States.MAIN_MENU

@export_group("States")

# Map the states to a given packed scene
# Will be instantiated whenever that scene is active. Otherwise is freed.
# Could track this other ways: we could export an array or dictionary, 
# but there is no need for that level of flexibility with 4-5 states and that introduces the
# possibility of effors. 
# Or we could use an autoload w/ change_scene, etc. Ultimately, small number of states,
# won't benefit from complexity.
@export var main_menu_scene: PackedScene
@export var overworld_scene: PackedScene
@export var combat_scene: PackedScene

# Track whichever state is currently active.
var current_state: States:
	set(value):
		if _state != null:
			_state.queue_free()
		
		current_state = value
		
		match current_state:
			States.MAIN_MENU:	_state = main_menu_scene.instantiate()
			States.OVERWORLD:	_state = overworld_scene.instantiate()
			States.COMBAT:		_state = combat_scene.instantiate()
		
		add_child(_state)
		_state.transition_executed.connect(func(next_state: States): current_state = next_state)
		
		_state.start.call_deferred()

# Track the reference to the active state node.
var _state: GameState = null


func _ready() -> void:
	assert(main_menu_scene, "Main needs a valid path to the main menu state PackedScene.")
	assert(overworld_scene, "Main needs a valid path to the overworld state PackedScene.")
	assert(combat_scene, "Main needs a valid path to the combat state PackedScene.")
	
	randomize()
	
	# Initialize the inventory.
	# TODO: This should occur whenever a "new game" is started.
	Inventory.create_inventory()
	var inventory: = Inventory.restore()
	inventory.add(Inventory.ItemTypes.KEY)
	Dialogic.VAR.RedWandCount = 1
	Dialogic.VAR.GreenWandCount = 1
	Dialogic.VAR.BlueWandCount = 1
	inventory.add(Inventory.ItemTypes.RED_WAND)
	inventory.add(Inventory.ItemTypes.GREEN_WAND)
	inventory.add(Inventory.ItemTypes.BLUE_WAND)
	inventory.save()
	
	# Start the game with the screen covered.
	await Transition.cover()
	
	current_state = initial_state
