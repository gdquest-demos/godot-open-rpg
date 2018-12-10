extends Pawn

class_name PawnActor

var game_board
signal moved(last_position, current_position)

onready var destination_point : = $DestinationPoint as Sprite

func _ready():
	update_look_direction(Vector2(1, 0))

func initialize(board):
	game_board = board

func update_look_direction(direction):
	return

func move_to(target_position):
	emit_signal("moved", position, target_position)
	set_process(false)

	# Move the node to the target cell instantly,
	# and animate the sprite moving from the start to the target cell
	var move_direction = (target_position - position).normalized()
	$Tween.interpolate_property($Pivot, "position", - move_direction * 32, Vector2(), $AnimationPlayer.current_animation_length, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$AnimationPlayer.play("walk")
	position = target_position

	$Tween.start()
	yield($AnimationPlayer, "animation_finished")
	set_process(true)
	
func bump():
	set_process(false)
	$AnimationPlayer.play("bump")
	yield($AnimationPlayer, "animation_finished")
	set_process(true)
