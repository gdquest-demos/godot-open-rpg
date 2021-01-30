extends CanvasLayer

class_name MonsterCollection

signal monster_collection_menu_summoned()

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

func _process(_delta):
	if(Input.is_action_just_released("ui_select")):
		emit_signal("monster_collection_menu_summoned")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
