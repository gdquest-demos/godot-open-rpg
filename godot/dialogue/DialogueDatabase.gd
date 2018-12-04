extends Node

const DIALOGUE_CHARACTERS = {
	"Godette": "res://dialogue/characters/GodetteDialogue.tres",
	"Robi": "res://dialogue/characters/RobiDialogue.tres",
}

func get_texture(character_name : String, expression : String) -> Texture:
	"""
	Gets the texture with the desired expression from a given character
	@return Texture with desired expression
	"""
	var resource = load(DIALOGUE_CHARACTERS[character_name])
	return resource.expression_textures[expression]