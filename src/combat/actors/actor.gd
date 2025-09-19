## An actor is any sort of class that will run an [Action] during combat.
##
## Actors provide logic to objects that want to act in combat. An actor is typically applied to a
## given [Battler], though other objects may wish to also make use of actors. For example, a combat
## event that deals damage to all battlers on every third turn would make use of a custom Actor,
## even though it is not present as a Battler.[/n][/n]
##
## Actors are sorted according to their initiative. Actors with higher initiative will act before
## those of lower initiative. Actors act sequentially, according to the logic provided to derived
## Actors.[/n][/n]
##
## [/b]Note:[/b] Actor provides the interface that derived classes will need in order to plug into
## the turn queue. For example, player actors will trigger the action selection UI, whereas AI
## actors may want to display a wide range of behaviours.
@abstract
class_name Actor extends Node2D

## Emitted whenever the actor's turn - including animations - has finished.
signal turn_finished

## The name of the node group that will contain all combat Actors.
const GROUP: = "_COMBAT_ACTOR_GROUP"

## Determines the order in which actors will take their turn. Higher initative actors act first.
@export_range(0.0, 1.0, 0.01) var initiative: = 1.0

@export var is_player: = false

## Describes whether or not the Actor has taken a turn during this combat round.
var has_acted_this_round: = false

## Is true if the Actor is currently able to contribute to the flow of combat. Inactive Actors do
## nothing and will not be used in the turn queue.
@export var is_active: = false


static func sort(a: Actor, b: Actor) -> bool:
	return a.initiative > b.initiative


func _ready() -> void:
	add_to_group(GROUP)


func start_turn() -> void:
	print(get_parent().name, " starts their turn!")
	
	await get_tree().create_timer(1.5).timeout
	turn_finished.emit()


func melee_attack() -> void:
	print("Attack!")


func _to_string() -> String:
	var msg: = "%s (Actor)" % name
	if not is_active:
		msg += " - INACTIVE"
	elif has_acted_this_round:
		msg += " - HAS ACTED"
	return msg
