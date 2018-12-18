extends PawnActor
class_name InteractivePawn

onready var raycasts : = $Raycasts as Node2D
onready var dialogue_balloon : = $DialogueBalloon as Sprite

export var vanish_on_interaction : = false
export var auto_start_interaction : = false
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

func _process(delta : float) -> void:
	if Input.is_action_just_pressed("ui_accept") and dialogue_balloon.visible:
		start_interaction()

func _physics_process(delta : float) -> void:
	var interacting = 0
	for raycast in raycasts.get_children():
		if raycast.is_colliding() and raycast.get_collider() is PawnLeader:
				if not is_interacting:
					if auto_start_interaction:
						start_interaction()
					else:
						dialogue_balloon.show()
				interacting += 1
	is_interacting = interacting > 0
	if dialogue_balloon.visible and not is_interacting:
		dialogue_balloon.hide()

func _on_body_entered(body : PhysicsBody2D) -> void:
	is_interacting = true
	if auto_start_interaction:
		start_interaction()
	else:
		dialogue_balloon.show()

func _on_body_exited(body : PhysicsBody2D) -> void:
	is_interacting = false
	dialogue_balloon.hide()

func start_interaction() -> void:
	dialogue_balloon.hide()
	for action in $Actions.get_children():
		yield(action.interact(), "completed")
	if vanish_on_interaction:
		queue_free()