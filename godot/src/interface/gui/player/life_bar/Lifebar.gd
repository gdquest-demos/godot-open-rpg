extends Control

signal maximum_changed(maximum)

var maximum = 100
var current_health = 0


func initialize(health_node):
	health_node.connect('health_changed', self, '_on_Player_Health_health_changed')
	maximum = health_node.max_health
	current_health = health_node.health
	emit_signal("maximum_changed", maximum)
	animate_bar(current_health)


func _on_Player_Health_health_changed(new_health):
	animate_bar(new_health)
	current_health = new_health


func animate_bar(target_health):
	$TextureProgress.animate_value(current_health, target_health)
	$TextureProgress.update_color(target_health)
