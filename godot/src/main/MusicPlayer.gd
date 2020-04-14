extends AudioStreamPlayer

const battle_theme = preload("res://assets/audio/bgm/battle_theme.ogg")
const victory_fanfare = preload("res://assets/audio/bgm/victory_fanfare.ogg")


func play_battle_theme():
	stream = battle_theme
	play()


func play_victory_fanfare():
	stream = victory_fanfare
	play()
