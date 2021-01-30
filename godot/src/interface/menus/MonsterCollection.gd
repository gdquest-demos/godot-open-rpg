extends CanvasLayer

class_name MonsterCollection

signal monster_collection_menu_summoned()

var slimes = []
onready var party = $Background/Columns/Party
onready var collection = $Background/Columns/Collection
var battler_path = "assets/sprites/battlers/"
var battler_ext = "_Slime_128.png"

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

func _ready():
	pass # Replace with function body.

func _process(_delta):
	if(Input.is_action_just_released("ui_select")):
		emit_signal("monster_collection_menu_summoned")

enum TEMPLATE { IMG = 0, NAME }
func reload():
	# First few children are labels etc and the main character; clear everything else and then start copying it
	print("party size %s" % [party.get_child_count()])
	while collection.get_child_count() > 3:
		collection.remove_child(collection.get_child(3))
	for i in range(0, slimes.size()):
		var l = slimes[i]
		var t = collection.get_node("CollMember/CollContainer").duplicate()
		t.get_child(TEMPLATE.IMG).texture = Data.getTexture(battler_path, "Red", battler_ext)
		labelCell(t, TEMPLATE.NAME, "Slime")
		t.visible = true
		collection.add_child(t)
	get_parent().emit_signal("draw")

func showingCat(c):
	var btn = $LogList/Filter.get_children()[c + 1]
	return btn.pressed

func labelCell(t, posn, data):
	var lbl : Label = t.get_child(posn)
	lbl.text = str(data)
