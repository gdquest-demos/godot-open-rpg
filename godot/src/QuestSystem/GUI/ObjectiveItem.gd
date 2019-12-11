extends HSplitContainer
class_name ObjectiveItem


const ICONS : = {
	unfinished = preload("res://assets/sprites/icons/quest_objective_unfinished.png"),
	finished = preload("res://assets/sprites/icons/quest_objective_finished.png")
}

var _icon : TextureRect = null
var _description : RichTextLabel = null


func setup(objective: Dictionary) -> void:
	_icon.texture = ICONS[objective.status]
	_description.bbcode_text = objective.description
	_description.bbcode_text += " [b](Bonus)[/b]" if objective.type == "bonus" else ""


func _ready() -> void:
	_icon = $Icon
	_description = $Description