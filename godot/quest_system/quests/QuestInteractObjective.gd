extends QuestObjective
class_name QuestInteractObjective

export var interact_with : PackedScene

func _ready() -> void:
	for interactive_pawn in get_tree().get_nodes_in_group("interactive_pawns"):
		interactive_pawn.connect("interaction_finished", self, "_on_InteractivePawn_interaction_finished")

func _on_InteractivePawn_interaction_finished(pawn) -> void:
	if pawn.filename == interact_with.resource_path and not completed:
		finish()

func as_text() -> String:
	return "Speak with: %s %s" % [interact_with.instance().name, "(completed)" if completed else ""]
