@tool
class_name Pickup extends Trigger

#TODO: have central item definitions somehwere that can be read by tool scripts. Will come with
# inventory update. Probably shouldn't be hardcoded as constants, to allow definitions of new items
# on the fly.
# See also UIInventory.ICONS.
const ICONS: = {
	Inventory.ItemTypes.KEY: preload("res://assets/items/key.atlastex"),
	Inventory.ItemTypes.COIN: preload("res://assets/items/coin.atlastex"),
	Inventory.ItemTypes.BOMB: preload("res://assets/items/bomb.atlastex"),
	Inventory.ItemTypes.RED_WAND: preload("res://assets/items/wand_red.atlastex"),
	Inventory.ItemTypes.BLUE_WAND: preload("res://assets/items/wand_blue.atlastex"),
	Inventory.ItemTypes.GREEN_WAND: preload("res://assets/items/wand_green.atlastex"),
}

@export var item_type: Inventory.ItemTypes:
	set(value):
		item_type = value
		
		if not is_inside_tree():
			await ready
		
		_sprite.texture = ICONS.get(item_type)
		
@export var amount: = 1

@onready var _anim: AnimationPlayer = $AnimationPlayer
@onready var _sprite: Sprite2D = $Sprite2D


func _execute() -> void:
	_anim.play("PickupAnimations/obtain")
	Inventory.restore().add(item_type, amount)
	
	await _anim.animation_finished
	queue_free()
