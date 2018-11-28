extends AudioStreamPlayer

const battle_theme = preload("res://assets/audio/bgm/battle_theme.ogg")

func _on_Game_combat_started() -> void:
	stream = battle_theme
	play()

func _on_Game_combat_finished() -> void:
	stop()
