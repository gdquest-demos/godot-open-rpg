@tool
extends Gamepiece

@export var item_type: Inventory.ItemTypes
@export var amount: = 1

@onready var interaction: = $Interaction as Interaction


func _ready() -> void:
	super._ready()
	
	if not Engine.is_editor_hint():
		interaction.item_type = item_type
		interaction.amount = amount
