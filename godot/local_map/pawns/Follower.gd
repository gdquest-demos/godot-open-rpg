extends "Actor.gd"

func _on_Actor_moved(last_position, current_position):
	follow(last_position)

func follow(to_position):
	var direction = (to_position - position).normalized()
	update_look_direction(direction)
	
	Grid.request_move(self, direction)
	move_to(to_position)
