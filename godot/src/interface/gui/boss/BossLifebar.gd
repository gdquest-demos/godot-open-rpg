tool
extends Control

export (String) var boss_name = "Boss Name"

onready var bar = $Bar
onready var anim_player = $AnimationPlayer


func _ready():
	set_as_toplevel(true)
	$Label.text = boss_name
	hide()


func initialize(health_node):
	bar.max_value = health_node.max_health
	bar.value = health_node.health
	health_node.connect('health_changed', self, '_on_Health_health_changed')


func appear():
	show()
	anim_player.play("appear")


func disappear():
	anim_player.play("disappear")
	yield(anim_player, "animation_finished")
	hide()


func _on_Health_health_changed(value):
	bar.value = value
