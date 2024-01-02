@tool

class_name WandPedestalInteraction extends InteractionTemplateConversation

signal colour_changed()

#TODO: will be replaced by proper inventory items (w/ sprites & icons) during the inventory update.
const ICONS: = {
	"red": preload("res://assets/items/wand_red.atlastex"),
	"blue": preload("res://assets/items/wand_blue.atlastex"),
	"green": preload("res://assets/items/wand_green.atlastex")
}

@export var wand_placed_timeline: DialogicTimeline

var colour: = ""

@onready var unoccupied_timeline: = timeline
@onready var _sprite: = $Sprite2D as Sprite2D


func _execute() -> void:
	timeline = unoccupied_timeline
	if _sprite.texture:
		timeline = wand_placed_timeline
	
	# There's a chance that we won't receive the signal (i.e. if the user opts to do nothing),
	# therefore we'll explicitly connect and disconnect this signal each time the interaction is
	# run. This will prevent overlap between multiple pedestals.
	Dialogic.signal_event.connect(_on_wand_placed)
	await super._execute()
	Dialogic.signal_event.disconnect(_on_wand_placed)


func _on_wand_placed(argument: String) -> void:
	match argument:
		"red":
			Inventory.restore().remove(Inventory.ItemTypes.RED_WAND)
		"blue":
			Inventory.restore().remove(Inventory.ItemTypes.BLUE_WAND)
		"green":
			Inventory.restore().remove(Inventory.ItemTypes.GREEN_WAND)
		"empty":
			match _sprite.texture:
				ICONS.red:
					Inventory.restore().add(Inventory.ItemTypes.RED_WAND)
				
				ICONS.blue:
					Inventory.restore().add(Inventory.ItemTypes.BLUE_WAND)
				
				ICONS.green:
					Inventory.restore().add(Inventory.ItemTypes.GREEN_WAND)
	
	_sprite.texture = ICONS.get(argument) # Will default to null if not one of the wands.
	
	colour = argument
	colour_changed.emit()
