## The entry point for the application.
## Specifies and manages game "states", allows transitions to whichever is active at a given moment.
extends Node2D

## Discrete, relatively simple, transitions easily mapped out
enum States { SPLASH, MAIN_MENU, OVERWORLD, COMBAT }

# The entry point for the app.
@export var initial_state: States = States.SPLASH

@export_group("State Paths")

# Map the states to a given packed scene
# Will be instantiated whenever that scene is active. Otherwise is freed.
# Could track this other ways: we could export an array or dictionary, 
# but there is no need for that level of flexibility with 4-5 states and that introduces the
# possibility of effors. 
# Or we could use an autoload w/ change_scene, etc. Ultimately, small number of states,
# won't benefit from complexity.
@export_file("*.tscn") var splash_scene: String
@export_file("*.tscn") var main_menu_scene: String
@export_file("*.tscn") var overworld_scene: String
@export_file("*.tscn") var combat_scene: String

# Track whichever state is currently active.
var current_state: States:
	set(value):
		if _state != null:
			_state.queue_free()
			_state = null
		
		current_state = value
		
		var next_state_path: = main_menu_scene
		match current_state:
			States.SPLASH:		next_state_path = splash_scene
			States.MAIN_MENU:	next_state_path = main_menu_scene
			States.OVERWORLD:	next_state_path = overworld_scene
			States.COMBAT:		next_state_path = combat_scene
		
		var packed_scene: = load(next_state_path)
		_state = packed_scene.instantiate()
		add_child(_state)

# Track the reference to the active state node.
var _state: Node = null


func _ready() -> void:
	assert(splash_scene, "Main needs a valid path to the splash screen state PackedScene.")
	assert(main_menu_scene, "Main needs a valid path to the main menu state PackedScene.")
	assert(overworld_scene, "Main needs a valid path to the overworld state PackedScene.")
	assert(combat_scene, "Main needs a valid path to the combat state PackedScene.")
	
	current_state = initial_state
