tool
extends Node

class_name Job

onready var stats = $Stats
onready var skills = $Skills

export var starting_stats : Resource

func _ready():
	stats.initialize(starting_stats)
