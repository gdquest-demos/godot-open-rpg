extends HSplitContainer
class_name RewardItem


onready var description : RichTextLabel = $Description


func setup(reward: String) -> void:
	description.bbcode_text = reward