## A battle actor is any character or object that performs actions during combat.
## This could be a player, an enemy, or even special events like traps or timed effects.
##
## Actors provide logic to objects that want to act in combat. An actor is typically applied to a
## given [Battler], though other objects may wish to also make use of actors. For example, a combat
## event that deals damage to all battlers on every third turn would make use of a custom CombatActor,
## even though it is not present as a Battler.[br][br]
##
## Actors take turns based on their initiative value. Higher initiative means
## they act earlier in the turn order. Each actor completes their full turn before
## the next one begins, following whatever logic you define in your custom actor classes.[br][br]
##
## [b]Important:[/b] This CombatActor class is like a template that specific actor types extend.
## For example, a player-controlled actor would show the action menu UI, while an AI enemy
## might have different attack patterns or decision-making logic.
@abstract
class_name CombatActor extends Node2D

## Emitted whenever the actor's turn is finished. You should emit this only
## after all actions and animations are complete.
signal turn_finished

## The name of the node group that will contain all combat Actors.
const GROUP: = "combat_actors"

## Influences when this actor takes their turn in combat. This is a speed rating:
## actors with higher initiative values (closer to 1.0) will act earlier in the turn order,
## while lower values (closer to 0.0) make them act later.
@export_range(0.0, 1.0, 0.01) var initiative := 1.0
## If this is [b]true[/b], this actor takes part in the battle. Inactive actors won't take turns.
@export var is_active: = false
## If this is [b]true[/b], this actor is controlled by the player. Use this to
## differentiate between player-controlled actors and AI-controlled ones.
@export var is_player: = false

## Describes whether or not the CombatActor has taken a turn during this combat round.
var has_acted_this_round: = false


static func sort(a: CombatActor, b: CombatActor) -> bool:
	return a.initiative > b.initiative


func _ready() -> void:
	add_to_group(GROUP)


func _to_string() -> String:
	var msg: = "%s (CombatActor)" % name
	if not is_active:
		msg += " - INACTIVE"
	elif has_acted_this_round:
		msg += " - HAS ACTED"
	return msg


func melee_attack() -> void:
	print("Attack!")


func start_turn() -> void:
	print(get_parent().name, " starts their turn!")

	await get_tree().create_timer(1.5).timeout
	turn_finished.emit()
