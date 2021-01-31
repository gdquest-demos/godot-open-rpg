extends MapAction

class_name MapTransition

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var target_map: String
export var current_map: String
export var spawn_x: int
export var spawn_y: int

func interact():
	var game_node = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	#game_node.clear_maps()
	#var new_map = game_node.get_node("LocalMap2")
	#new_map.visible = true
	
	local_map = get_parent().get_parent().get_parent().get_parent().get_parent()
	#local_map = game_node.get_node(current_map)
	
	local_map.queue_free()
	
	var new_map = load(target_map).instance()
	
	var spawn_point = new_map.get_node("GameBoard/SpawningPoint")
	spawn_point.set_global_position(Vector2(spawn_x, spawn_y))
	
	game_node.add_child(new_map)
	
	var gb = new_map.get_node("GameBoard")
	var ysort = gb.get_node("Pawns")
	ysort.spawn_party(gb, game_node.get_node("Party"))
	
	
	#ysort.rebuild_party()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
