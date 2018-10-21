extends CanvasLayer

onready var lifebar_builder = $LifebarsBuilder

func initialize(battlers : Array):
	lifebar_builder.initialize(battlers)
