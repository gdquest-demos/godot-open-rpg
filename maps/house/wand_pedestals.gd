extends Node2D

@onready var _blue: = $BluePedestal as WandPedestalInteraction
@onready var _green: = $GreenPedestal as WandPedestalInteraction
@onready var _red: = $RedPedestal as WandPedestalInteraction

@onready var _audio: = $SpikesClick
@onready var _spikes: = $PathBlocker


func _ready() -> void:
	var inventory: = Inventory.restore()
	inventory.item_changed.connect(_on_inventory_item_changed.bind(inventory))
	
	#_blue.colour_changed.connect(_on_wand_placed)
	#_green.colour_changed.connect(_on_wand_placed)
	#_red.colour_changed.connect(_on_wand_placed)


func _on_wand_placed() -> void:
	if _blue.colour == "blue" and _green.colour == "green" and _red.colour == "red":
		_blue.is_active = false
		_green.is_active = false
		_red.is_active = false
		
		_audio.play()
		
		# The physics engine will take a few frames to account for the missing spikes, so we need
		# to wait to update the pathfinder until then.
		# The first frame waits until the "spikes" blocking area has been freed. The second frame
		# waits until the physics engine has registered the change in collision objects.
		_spikes.queue_free()
		await get_tree().physics_frame
		await get_tree().physics_frame
		FieldEvents.terrain_changed.emit()


func _on_inventory_item_changed(item_type: Inventory.ItemTypes, inventory: Inventory) -> void:
	match item_type:
		Inventory.ItemTypes.RED_WAND:
			Dialogic.VAR.set_variable("RedWandCount", inventory.get_item_count(item_type))
		
		Inventory.ItemTypes.BLUE_WAND:
			Dialogic.VAR.set_variable("BlueWandCount", inventory.get_item_count(item_type))
			
		Inventory.ItemTypes.GREEN_WAND:
			Dialogic.VAR.set_variable("GreenWandCount", inventory.get_item_count(item_type))
