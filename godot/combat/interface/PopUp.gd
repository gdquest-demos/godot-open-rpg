extends Control

func initialize(battlers : Array) -> void:
	for battler in battlers:
		_connect_value_signals(battler)
	
func _connect_value_signals(battler : Battler) -> void:
	var battler_stats = battler.stats
	battler_stats.connect("health_changed", self, "_on_value_changed", [battler])

func _on_value_changed(new_value, old_value, battler) -> void:
	var value = new_value - old_value
	rect_position = Vector2(battler.position.x, battler.position.y - 150)
	$Label.text = str(value)
	if value <= 0:
		$AnimationPlayer.play("damage")
	else:
		$AnimationPlayer.play("heal")

