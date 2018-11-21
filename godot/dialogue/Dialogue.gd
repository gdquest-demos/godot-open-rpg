extends Node

export (String, FILE, "*.json") var file_path : String

func load() -> Dictionary:
	"""
	Parse a JSON file and returns it or an empty dictionary if the
	file doesn't exist.
	"""
	
	var file = File.new()
	
	if file.file_exists(file_path):
		file.open(file_path, file.READ)
		var dialogue = parse_json(file.get_as_text())
		return dialogue
	
	return {}
