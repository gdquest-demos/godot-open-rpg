extends Node

export(PackedScene) var skill_action_scene

func initialize(skills : Array) -> void:
	for skill in skills:
		var new_skill = skill_action_scene.instance()
		new_skill.skill_to_use = skill
		add_child(new_skill)
