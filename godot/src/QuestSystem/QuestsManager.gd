extends Node


signal quest_added(q)

var quests : = {
	inactive = {},
	active = {},
	finished = {}
}


func setup(file_path: String) -> void:
	var qs : = _read_quests(file_path)
	_populate(qs)


func _populate(qs: Dictionary) -> void:
	for key in qs:
		var q : Dictionary = qs[key]
		quests[q.status][key] = q
		emit_signal("quest_added", q)


func _read_quests(file_path: String) -> Dictionary:
	var out = {}
	
	var f : = File.new()
	var error = f.open(file_path, File.READ)
	assert(error == OK)
	var parsed : = JSON.parse( f.get_as_text())
	f.close()
	
	assert(parsed.error == OK)
	for key in parsed.result:
		out[int(key)] = parsed.result[key]
	return out
