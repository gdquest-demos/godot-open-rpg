extends Node
class_name Actor, "res://assets/nodes/actor.svg"
# Base class that can be extended from to give access to behaviors.
#
# By itself this script doesn't do anything useful. To make use of it we have to create additional
# Behaviors and make use of them. We reroute work from the parent class to the Behavior nodes.
#
# Apart from rerouting work to Behaviors, extended classes from Actor should only hold data and no
# other functionality. All child nodes of Actor should be used only for holding data and only
# Behavior node themselves offer functionality. Check `NoOpBehavior.gd` for more info on Behaviors.
#
#
# Notes
# -----
# There's an implicit `NopOp` Behavior that gets attached as a child node when Actor becomes ready.
# The noop behavior does't do anything, hence the name noop (No Operation). To make this useful we
# have to attach other nodes that have the same Behavior interface and operate on `root_node`.
#
# Say we have this node structure to begin with:
#
#	Player :: extending Actor
#	|
#	+-- Sprite
#	+-- Camera
#	+-- Walk :: extending Behavior
#	+-- Attack :: extending Behavior
#
# At run-time the tree will become:
#
#	Player :: extending Actor
#	|
#	+-- Sprite
#	+-- Camera
#	+-- walk :: extending Behavior
#	+-- attack :: extending Behavior
#	+-- noop :: NoOpBehavior
#
# For convinience, Behavior node names are lower-case at runtime so when calling
# `get_behavior(name)`, `name` can be any mixed case, but most likely it will be lower-case.


func register(behavior: Behavior) -> void:
	not has_behavior(behavior.name) and add_child(behavior)


func unregister(behavior: Behavior) -> void:
	if not behavior.is_noop() and has_behavior(behavior.name):
		remove_child(behavior)
		behavior.queue_free()


func has_behavior(behavior_name: String) -> bool:
	return has_node(behavior_name) and get_node(behavior_name) is Behavior


func get_behavior(behavior_name: String) -> Node:
	var noop : = get_node("noop")
	var node : = get_node(behavior_name) if has_node(behavior_name) else noop
	return node if node is Behavior else noop


func _ready() -> void:
	register(preload("res://src/Actor/NoOpBehavior.tscn").instance())
