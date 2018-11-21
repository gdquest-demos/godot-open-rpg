extends Node

export (String, FILE, "*.json") var dialogue_file : String

func load_dialogue() -> Dictionary:
	"""
	Parse a JSON file and returns it or an empty dictionary if the
	file doesn't exist.
	"""
	
	var file = File.new()
	
	if file.file_exists(dialogue_file):
		file.open(dialogue_file, file.READ)
		
		var dialogue = parse_json(file.get_as_text())
		
		return dialogue
	return {}