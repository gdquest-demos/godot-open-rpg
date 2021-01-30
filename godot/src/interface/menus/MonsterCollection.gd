extends CanvasLayer

class_name MonsterCollection

var slimes = []

func add_slime(new_slime: Slime) -> void:
	slimes.resize(slimes.size() + 1)
	slimes[slimes.size() - 1] = new_slime
	
func remove_slime(target_pos: int) -> Slime:
	var rv = slimes[target_pos]
	slimes.remove(target_pos)
	return rv

func get_slime(target_pos: int) -> Slime:
	var rv = slimes[target_pos]
	return rv
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
