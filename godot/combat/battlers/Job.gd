tool
extends Node

class_name Job

onready var stats = $Stats
onready var skills = $Skills

export var starting_stats : Resource

func _ready():
	if Engine.editor_hint:
		name = starting_stats.job_name
		return
	stats.initialize(starting_stats)
