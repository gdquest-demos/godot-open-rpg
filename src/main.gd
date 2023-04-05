extends Node


func _ready() -> void:
	randomize()
	
	# The following will become more complex in the future as other gamestates are invovled.
	$States/Field.enter.call_deferred({})
