extends Position2D

class_name BattlerAnim

onready var anim = $AnimationPlayer
onready var extents: RectExtents = $RectExtents


func play_stagger():
	anim.play("take_damage")
	yield(anim, "animation_finished")


func play_death():
	anim.play("death")
	yield(anim, "animation_finished")
