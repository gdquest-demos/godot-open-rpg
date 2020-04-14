extends PawnActor

class_name PawnFollower


func _on_target_Pawn_moved(last_position, current_position):
	follow(last_position)


func follow(target_position):
	var direction = (target_position - position).normalized()
	update_look_direction(direction)

	move_to(target_position)
