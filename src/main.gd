extends Node


func _ready() -> void:
	randomize()
	
	$Field.initialize.call_deferred()
