@tool
class_name Pickup extends Trigger

@export var item_type: Inventory.ItemTypes:
	set(value):
		item_type = value
		
		if not is_inside_tree():
			await ready
		
		_sprite.texture = Inventory.get_item_icon(item_type)
		
@export var amount: = 1

@onready var _anim: AnimationPlayer = $AnimationPlayer
@onready var _sprite: Sprite2D = $Sprite2D


func _execute() -> void:
	_anim.play("PickupAnimations/obtain")
	Inventory.restore().add(item_type, amount)
	
	await _anim.animation_finished
	queue_free()
