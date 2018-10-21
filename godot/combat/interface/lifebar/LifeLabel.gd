extends Label

func display(health : int, max_health : int):
	text = "%s/%s" % [health, max_health]
