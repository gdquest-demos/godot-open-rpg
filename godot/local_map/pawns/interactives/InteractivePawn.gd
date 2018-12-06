extends "res://local_map/pawns/Pawn.gd"
class_name InteractivePawn

signal interacted(type, arg)

onready var raycasts : = $Raycasts as Node2D

export var vanish_on_interaction : = false
export var sight_distance = 50
export var facing = {
	"up": true,
	"left": true,
	"right": true,
	"down": true
}

var is_interacting : bool = false

func _ready() -> void:
	connect('body_entered', self, '_on_body_entered')
	connect('body_exited', self, '_on_body_exited')
	
	var enable_process = 0
	for raycast in raycasts.get_children():
		raycast.enabled = facing[raycast.name.to_lower()]
		raycast.cast_to *= sight_distance
		enable_process += int(raycast.enabled)
	set_physics_process(enable_process > 0)

func _physics_process(delta : float) -> void:
	var interacting = 0
	for raycast in raycasts.get_children():
		if raycast.is_colliding() and raycast.get_collider() is PawnLeader:
				if not is_interacting:
					start_interaction()
				interacting += 1
	is_interacting = interacting > 0

func _on_body_entered(body : PhysicsBody2D) -> void:
	is_interacting = true
	start_interaction()

func _on_body_exited(body : PhysicsBody2D) -> void:
	is_interacting = false

func start_interaction() -> void:
	for interaction in $Interactions.get_children():
		yield(interaction.interact(), "completed")
	if vanish_on_interaction:
		queue_free()