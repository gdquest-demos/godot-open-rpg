@tool

class_name WandPedestalInteraction extends InteractionTemplateConversation

const REMOVE_WAND_ARGUMENT: = "EMPTY"

@export var wand_placed_timeline: DialogicTimeline

var current_item_id: = -1

@onready var unoccupied_timeline: = timeline
@onready var _sprite: = $Sprite2D as Sprite2D


func _execute() -> void:
	timeline = unoccupied_timeline
	if _sprite.texture:
		timeline = wand_placed_timeline
	
	# There's a chance that we won't receive the signal (i.e. if the user opts to do nothing),
	# therefore we'll explicitly connect and disconnect this signal each time the interaction is
	# run. This will prevent overlap between multiple pedestals.
	Dialogic.signal_event.connect(_on_dialogic_signal_event)
	await super._execute()
	Dialogic.signal_event.disconnect(_on_dialogic_signal_event)


# Is called from a signal event within a Dialogic timeline. Note that this is only bound to the
# timeline that is run from THIS particular pedestal.
# The following method ensures that the designer has passed a correct item id string from Dialogic,
# and either adds a wand to the pedestal or pulls one off.
func _on_dialogic_signal_event(argument: String) -> void:
	# The pedestal should only accept a subset of inventory items: a type of wand.
	# We should also accept an option to pull a wand off the pedestal, which is defined by a
	# constant at the beginning of the file.
	var valid_keys: = Inventory.ItemTypes.keys().filter(func(type): return "WAND" in type)
	valid_keys.append(REMOVE_WAND_ARGUMENT)
	
	# If the item added to the pedestal by Dialogic is incorrect, print and error so that the
	# designer knows to change the item type.
	if not argument.to_upper() in valid_keys:
		printerr("%s::_on_wand_placed() error: Dialogic timeline did not pass an "  % name
			+ "Inventory.ItemTypes key as argument!")
		return
	
	# The pedestals will track which item is on them via the item ID. This is the value of the
	# Inventory.ItemTypes enum (which corresponds to the key, which is a string such as "Coin").
	# Note that an argument that is not found within Inventory.ItemTypes will return -1, an invalid
	# value that will trigger the "remove item from pedestal" condition.
	var item_id: = Inventory.ItemTypes.get(argument, -1) as int
	if item_id < 0:
		if current_item_id in Inventory.ItemTypes.values():
			Inventory.restore().add(current_item_id)
	
	else:
		Inventory.restore().remove(item_id)
	
	# The item_id shows what is currently on the pedestal. Set the sprite's texture to match.
	current_item_id = item_id
	_sprite.texture = Inventory.get_item_icon(item_id)
