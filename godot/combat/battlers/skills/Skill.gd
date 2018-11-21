extends Resource

class_name Skill

export var skill_name : String = "Skill"
export var skill_description : String = ""

export var mana_cost : int
export var base_damage : int
export(float, 0.0, 1.0) var success_chance : float
