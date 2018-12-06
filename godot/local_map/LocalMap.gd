extends Node
class_name LocalMap

signal enemies_encountered(formation)
signal combat_finished()

func spawn_party(party) -> void:
	$Grid/Pawns.spawn_party(party, $Grid.map_to_world(Vector2(2,2)))

func start_encounter(formation) -> void:
	emit_signal("enemies_encountered", formation.instance())

func _on_Game_combat_finished():
	emit_signal("combat_finished")
