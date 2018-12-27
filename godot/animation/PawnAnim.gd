extends Position2D

class_name PawnAnim

onready var anim = $AnimationPlayer

func play_walk():
	anim.play("walk")
	yield(anim, "animation_finished")

func play_bump():
	anim.play("bump")
	yield(anim, "animation_finished")

func get_current_animation_length():
	return anim.current_animation_length
