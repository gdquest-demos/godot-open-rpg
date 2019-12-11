extends Node2D
class_name Battler

onready var stats : Stats = $Stats

var _sprite : Sprite = null
var _skills : Control = null


func setup() -> void:
	var offset = _sprite.texture.get_height()
	_sprite.position.y = -offset/2


func _ready() -> void:
	_sprite = $Skin
	_skills = $Skills
	
	Events.connect("battle_started", self, "_on_Events_battle", ["started"])
	Events.connect("battle_finished", self, "_on_Events_battle", ["finished"])
	setup()


func _on_Events_battle(msg: Dictionary = {}, which: String = "") -> void:
	visible = true if which == "started" else false