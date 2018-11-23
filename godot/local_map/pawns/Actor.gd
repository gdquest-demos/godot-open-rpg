extends "Pawn.gd"

onready var Grid = get_parent()

signal moved(last_position, current_position)
signal look_direction_changed(new_direction)

func _ready():
	update_look_direction(Vector2(1, 0))
	position = (Grid.request_move(self, Vector2(0, 0)))

func update_look_direction(direction):
	$Pivot/Sprite.rotation = direction.angle()
	emit_signal("look_direction_changed", direction)

func move_to(target_position):
	var current_position = position
	emit_signal("moved", current_position, position)
	set_process(false)
	$AnimationPlayer.play("walk")

	# Move the node to the target cell instantly,
	# and animate the sprite moving from the start to the target cell
	var move_direction = (target_position - position).normalized()
	$Tween.interpolate_property($Pivot, "position", - move_direction * 32, Vector2(), $AnimationPlayer.current_animation_length, Tween.TRANS_LINEAR, Tween.EASE_IN)
	position = target_position

	$Tween.start()

	# Stop the function execution until the animation finished
	yield($AnimationPlayer, "animation_finished")
	
	set_process(true)
	
func bump():
	set_process(false)
	$AnimationPlayer.play("bump")
	yield($AnimationPlayer, "animation_finished")
	set_process(true)
