extends Node

signal enemies_encountered(formation)
signal dialogue(dialogue)

func spawn_party(party) -> void:
	$Grid/Pawns.spawn_party(party, $Grid.map_to_world(Vector2(2,2)))

func _on_Grid_interaction_happened(type, arg):
	match type:
		InteractablePawn.InteractionType.DIALOGUE:
			$MapInterface/DialogueBox.initialize(arg.load())
		InteractablePawn.InteractionType.COMBAT:
			emit_signal("enemies_encountered", arg.instance())
