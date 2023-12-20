extends DialogicNode_StyleLayer


func _ready():
	super._ready()
	set_process_input(false)
	
	Dialogic.timeline_started.connect(func(): 
			show()
			set_process_input(true)
	)
	Dialogic.timeline_ended.connect(
		func(): 
			hide()
			set_process_input(false)
	)
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		print("CONSUME EVENT")
		get_viewport().set_input_as_handled()
