extends Position2D

class_name BattlerAnim

onready var anim = $AnimationPlayer

func stagger():
	anim.play("take_damage")
