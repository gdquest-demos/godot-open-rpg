extends Interaction


func _execute() -> void:
	$Timer.start(	)
	await $Timer.timeout
	
	print("Test interaction works")
	
