class_name Interactable
extends Area2D

signal interacted

@export var trigger_nodes: Array[Interactable] = []

func _ready() -> void:
	area_entered.connect(func (area: Area2D) -> void: 
		var gamepiece: = area.owner as Gamepiece
		if gamepiece:
			if gamepiece.is_travelling():
				await gamepiece.arriving
			_on_gamepiece_entered()
	)

## Connects external triggers. For example, for a door, it could be
## a key, a list of keys; Or maybe a series of switches.
## the function returns the amount of triggers because in many 
## situations, the order and type of trigger does not matter.
## for more complex situations, override and change the behavior.
func _setup_triggers() -> int:
	var remaining_triggers_count = trigger_nodes.size()
	for node in trigger_nodes:
		if not node.is_inside_tree():
			await node.ready
		node.interacted.connect(_on_trigger_interacted.bind(node))
		# node.tree_exited.connect(func (): trigger_nodes.erase(node))
	# clear the array to not keep uneeded references
	trigger_nodes.clear()
	return remaining_triggers_count


## Called when the player interacts with an object.
## Proxies the internal function `_on_interacted`.
## Maybe not necessary, we could call `_on_interacted` directly,
## But then naming probably needs to change
func run() -> void:
	_on_interacted()

## Runs when a trigger, registered with trigger_nodes array, is
## triggered
func _on_trigger_interacted(_trigger: Interactable) -> void:
	pass

## Runs when a gamepiece enters. Discriminate with physics layers
func _on_gamepiece_entered() -> void:
	pass

## Runs when players interacts with the Interactable
func _on_interacted() -> void:
	pass
