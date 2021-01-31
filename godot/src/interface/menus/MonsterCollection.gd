extends CanvasLayer

class_name MonsterCollection

signal monster_collection_menu_summoned()

var slimes = []
onready var party = $Background/Columns/Party
onready var collection = $Background/Columns/Collection
onready var artifacts = $Background/Columns/Artifacts

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
const FLAVOURS = [ "Red", "Blue", "Green" ]
const NAME_BASIC = [ "Red", "Blue", "Green" ]
const NAME_EVOLVED = [ "Fang", "Eye", "Scale" ]
const ARTIFACTS = [ "Fang", "Eye", "Scale" ]
var battler_path = "assets/sprites/battlers/"
var battler_ext = ".png"
var artifact_path = "assets/sprites/artifacts/"
var artifact_ext = ".png"
var num_in_party = 3
var num_artifacts = 3
var num_evolved = 0

func reload():
	# First few children are labels etc and the main character; clear everything else and then start copying it
	print("party size %s" % [party.get_child_count()])
	while party.get_child_count() > 3:
		party.remove_child(party.get_child(3))
	for i in range(0, num_in_party):
		var t = party.get_node("PartyMember/PartyContainer").duplicate()
		var img_file = FLAVOURS[i] + "_Slime_128"
		if i < num_evolved:
			img_file = NAME_EVOLVED[i] + "_Monster"
		t.get_child(TEMPLATE.IMG).texture = Data.getTexture(battler_path, img_file, battler_ext)
		labelCell(t, TEMPLATE.NAME, NAME_BASIC[i])
		t.visible = true
		party.add_child(t)
#	while collection.get_child_count() > 3:
#		collection.remove_child(collection.get_child(3))
#	for i in range(0, slimes.size()):
#		var l = slimes[i]
#		var t = collection.get_node("CollMember/CollContainer").duplicate()
#		t.get_child(TEMPLATE.IMG).texture = Data.getTexture(battler_path, "Red", battler_ext)
#		labelCell(t, TEMPLATE.NAME, "Slime")
#		t.visible = true
#		collection.add_child(t)
	while artifacts.get_child_count() > 3:
		artifacts.remove_child(artifacts.get_child(3))
	for i in range(num_evolved, num_artifacts):
		var t = artifacts.get_node("ArtifactMember/ArtifactContainer").duplicate()
		t.get_child(TEMPLATE.IMG).texture = Data.getTexture(artifact_path, ARTIFACTS[i], artifact_ext)
		labelCell(t, TEMPLATE.NAME, ARTIFACTS[i])
		t.visible = true
		artifacts.add_child(t)
	#get_parent().emit_signal("draw")
	pass

func labelCell(t, posn, data):
	var lbl : Label = t.get_child(posn)
	lbl.text = str(data)

func ascend(i):
	if i < num_in_party and i < num_artifacts:
		num_evolved += 1


func _on_MergeButton_button_down():
	ascend(num_evolved)
	reload()
