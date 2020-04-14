extends Node

const SOURCE_DIRECTORY = "res://src/dialogue/characters/"
var characters: Dictionary


func _ready() -> void:
	var dir = Directory.new()
	assert(dir.dir_exists(SOURCE_DIRECTORY))
	if not dir.open(SOURCE_DIRECTORY) == OK:
		print("Could not read directory %s" % SOURCE_DIRECTORY)
	dir.list_dir_begin()
	var file_name: String
	while true:
		file_name = dir.get_next()
		if file_name == "":
			break
		if not file_name.ends_with(".tres"):
			continue
		characters[file_name.get_basename()] = load(SOURCE_DIRECTORY.plus_file(file_name))


func get_texture(character_name: String, expression: String = "neutral") -> Texture:
	# Returns the Texture corresponding to a character's name and expression name
	assert(character_name in characters)
	assert(expression in characters[character_name].expressions)
	return characters[character_name].expressions[expression]
