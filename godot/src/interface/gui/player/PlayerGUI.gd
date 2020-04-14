extends Control


func initialize(health_node, purse):
	$LifeBar.initialize(health_node)
	$CoinsCounter.initialize(purse)
	health_node.connect('health_depleted', self, '_on_Player_Health_health_depleted')


func _on_Player_Health_health_depleted():
	$AnimationPlayer.play("fade_out")
