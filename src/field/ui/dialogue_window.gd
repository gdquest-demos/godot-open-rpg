extends DialogicNode_StyleLayer


func _ready():
	super._ready()
	
	Dialogic.timeline_started.connect(func(): show())
	Dialogic.timeline_ended.connect(func(): hide())
	hide()
