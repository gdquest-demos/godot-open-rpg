# Pawn that can move on the GameBoard and play animations
extends Pawn

class_name PawnActor

var game_board
signal moved(last_position, current_position)

onready var pivot = $Pivot
onready var tween = $Tween
onready var anim: PawnAnim = pivot.get_node("PawnAnim")


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
	position = target_position
	pivot.position = -move_direction * 40.0
	tween.interpolate_property(
		$Pivot,
		"position",
		pivot.position,
		Vector2(),
		anim.get_current_animation_length(),
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	tween.start()
	yield(anim.play_walk(), "completed")
	set_process(true)


func bump():
	set_process(false)
	yield(anim.play_bump(), "completed")
	set_process(true)


func change_skin(pawn_anim: PawnAnim):
	# Replaces the pawn's animated character with another
	if anim:
		anim.queue_free()
	anim = pawn_anim
	pivot.add_child(pawn_anim)
