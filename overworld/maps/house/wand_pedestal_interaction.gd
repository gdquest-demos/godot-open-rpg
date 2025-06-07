@tool

class_name WandPedestalInteraction extends InteractionTemplateConversation

## The pedestal should only accept a subset of inventory items: a type of wand.
## We should also accept an option to pull a wand off the pedestal, which is the integer associate
## with an invalid item.
const VALID_ITEMS: = [
	Inventory.ItemTypes.RED_WAND,
	Inventory.ItemTypes.BLUE_WAND,
	Inventory.ItemTypes.GREEN_WAND,
	-1
	]

## A list of ALL pedestals in the current scene that have the correct wand placed on them.
## The keys will be the pedestal itself, and the values whether or not a given pedestal is correct.
static var _correct_pedestals: = {}

## Link the obstacle's animation player to this object for when the puzzle is solved.
@export var spikes_animation: AnimationPlayer

## Specify a timeline that should be run if an item is already placed on the pedestal.
@export var wand_placed_timeline: DialogicTimeline

## Specify which wand color this pedestal expects.
@export_enum("Red", "Blue", "Green") var pedestal_requirement: = "Red"

## Keep track of the id of the item currently placed on the pedestal, from Inventory.ItemTypes enum.
var current_item_id: = -1

## Rename [InteractionTemplateConversation.timeline] to specify that it runs when no item is on
## the pedestal.
@onready var unoccupied_timeline: = timeline
@onready var _sprite: = $Sprite2D as Sprite2D


func _ready() -> void:
	super._ready()
	
	if not Engine.is_editor_hint():
		assert(spikes_animation, "This interaction requires the obstacle's animation player!")
		
		# Setup the static variable to account for this pedestal.
		_correct_pedestals[self] = false
		
		# TODO: can Dialogic access inventory somehow?
		# We want to use a few puzzle-specific Dialogic variables that need to change with the
		#  player's inventory. They may be linked through the following signal/callback pair.
		# Note that this will trigger multiple times, depending on how many pedestals exist. This is
		# irrelevant, since it is merely setting the variable to the inventory's value.
		var inventory: = Inventory.restore()
		inventory.item_changed.connect(_on_inventory_item_changed.bind(inventory))


func _execute() -> void:
	# Run the default timeline unless there is already something on this pedestal, in which case
	# we want to ask the player if they want to make a change to what is on it.
	timeline = unoccupied_timeline
	if _sprite.texture:
		timeline = wand_placed_timeline
	
	# There's a chance that we won't receive the signal (i.e. if the user opts to do nothing),
	# therefore we'll explicitly connect and disconnect this signal each time the interaction is
	# run. This will prevent overlap between multiple pedestals.
	await super._execute()
	
	# Check to see if the puzzle has been solved, waiting for its resolution (screen shake and
	# grating noises, for example) before finishing.
	if _is_puzzle_solved():
		# Deactivate the pedestal interactions so that they cannot be interacted with.
		for pedestal in _correct_pedestals.keys():
			pedestal.is_active = false
		
		# The referenced animation player will visually resolve the puzzle.
		spikes_animation.play("clear")
		await spikes_animation.animation_finished


# Check to see if ALL pedestals have the correct wand placed on them.
func _is_puzzle_solved() -> bool:
	for value in _correct_pedestals.values():
		if not value:
			return false
	return true


# This responds to a signal event within a Dialogic timeline. Note that this is only bound to the
# timeline that is run from THIS particular pedestal.
# The following method ensures that the designer has passed a correct item id string from Dialogic,
# and either adds a wand to the pedestal or pulls one off.
# Argument is expected to be the key (item type) of the Inventory.ItemTypes enum.
func _on_dialogic_signal_event(argument: String) -> void:
	# Convert the argument into an item id, as defined by the Inventory.ItemTypes enum.
	var item_id: = Inventory.ItemTypes.get(argument.to_upper(), -1) as int
	if not item_id in VALID_ITEMS:
		return
	
	# Convert the value specified by pedestal_requirement to an item id, as defined by the
	# Inventory.ItemTypes enum.
	var expected_wand: = pedestal_requirement.to_upper() + "_WAND"
	var expected_wand_id: = Inventory.ItemTypes.get(expected_wand, -1) as int
	
	# The pedestals will track which item is on them via the item ID. This is the value of the
	# Inventory.ItemTypes enum (which corresponds to the key, which is a string such as "Coin").
	# Note that an argument that is not found within Inventory.ItemTypes will return -1, an invalid
	# value that will trigger the "remove item from pedestal" condition.
	if item_id < 0:
		if current_item_id in Inventory.ItemTypes.values():
			Inventory.restore().add(current_item_id)
	
	else:
		Inventory.restore().remove(item_id)
	
	# The item_id shows what is currently on the pedestal. Set the sprite's texture to match.
	current_item_id = item_id
	_sprite.texture = Inventory.get_item_icon(item_id)
	
	# Finally, flag whether or not this pedestal has the correct wand placed on it.
	_correct_pedestals[self] = current_item_id == expected_wand_id


# Match puzzle-specific variables to the player's inventory.
func _on_inventory_item_changed(item_type: Inventory.ItemTypes, inventory: Inventory) -> void:
	match item_type:
		Inventory.ItemTypes.RED_WAND:
			Dialogic.VAR.set_variable("RedWandCount", inventory.get_item_count(item_type))
		
		Inventory.ItemTypes.BLUE_WAND:
			Dialogic.VAR.set_variable("BlueWandCount", inventory.get_item_count(item_type))
			
		Inventory.ItemTypes.GREEN_WAND:
			Dialogic.VAR.set_variable("GreenWandCount", inventory.get_item_count(item_type))
