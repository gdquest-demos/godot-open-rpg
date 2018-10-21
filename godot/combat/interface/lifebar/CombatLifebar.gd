extends Node2D

onready var bar = $Column/TextureProgress
onready var label = $Column/LifeLabel

var max_health = 0 setget set_max_health
var health = 0 setget set_health

export var LABEL_ABOVE : bool

func _ready():
	if LABEL_ABOVE:
		label.raise()

func set_max_health(value):
	max_health = value
	bar.max_value = value
	label.display(health, max_health)

func set_health(value):
	health = value
	bar.value = value
	label.display(health, max_health)

func initialize(battler : Battler):
	var anchor = battler.anchor
	global_position = anchor.global_position
	anchor.remote_path = anchor.get_path_to(self)
	
	var health_node = battler.health
	health_node.connect("health_changed", self, "_on_Battler_health_changed")
	health_node.connect("health_depleted", self, "_on_Battler_health_depleted")
	
	self.health = health_node.health
	self.max_health = health_node.max_health

func _on_Battler_health_changed(new_health):
	self.health = new_health
	
func _on_Battler_health_depleted():
	hide()
