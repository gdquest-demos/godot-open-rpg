extends Label


func display(value: int, max_value: int):
	text = "%s/%s" % [value, max_value]
