## Stores gamepiece references by position and provides methods to look them up by position or name.
class_name GamepieceDirectory
extends RefCounted

# Key = cell, value = weakref to Gamepiece object
var _gamepieces: = {}

# Since the gamepiece is a refcounted, we want to pass in a callable that can look up gamepiece
# nodes directly from the scene tree.
var _get_by_uid: Callable


func _init(get_by_uid_method: Callable) -> void:
	FieldEvents.gamepiece_initialized.connect(_on_gamepiece_initialized)
	
	_get_by_uid = get_by_uid_method


func get_occupied_cells() -> Array[Vector2i]:
	var occupied_cells: Array[Vector2i] = []
	for cell in _gamepieces.keys():
		occupied_cells.append(Vector2i(cell))
	return occupied_cells


func get_by_uid(uid: String) -> Gamepiece:
	return _get_by_uid.call(uid)


func get_by_cell(cell: Vector2i) -> Gamepiece:
	# We need a few checks to validate the output. First of all, ensure that a weakref is stored
	# at 'cell'. Secondly, the weakref must point to a valid gamepiece (note that weakrefs can
	# be invalidated if the gamepiece no longer exists for some reason).
	if _gamepieces.has(cell):
		var gp_weakref: = _gamepieces.get(cell) as WeakRef
		if gp_weakref:
			var gamepiece: = gp_weakref.get_ref() as Gamepiece
			if gamepiece:
				return gamepiece
		
		# Something invalid is stored at cell, so clean it up.
		_gamepieces.erase(cell)
	
	return null


func get_by_area(cells: Array[Vector2i]) -> Array[Gamepiece]:
	var gamepieces: Array[Gamepiece] = []
	for cell in cells:
		var gamepiece: = get_by_cell(cell)
		if gamepiece:
			gamepieces.append(gamepiece)
	return gamepieces


func get_gamepieces() -> Array[Gamepiece]:
	var occupied_cells: = get_occupied_cells()
	return get_by_area(occupied_cells)


func _on_gamepiece_initialized(gamepiece: Gamepiece) -> void:
	if _gamepieces.has(gamepiece.cell):
		gamepiece.queue_free()
		return
	
	_gamepieces[gamepiece.cell] = weakref(gamepiece)
	gamepiece.cell_changed.connect(_on_gamepiece_moved.bind(gamepiece))
	gamepiece.freed.connect(_on_gamepiece_freed.bind(gamepiece))


func _on_gamepiece_moved(old_cell: Vector2i, gamepiece: Gamepiece) -> void:
	if _gamepieces.has(old_cell):
		_gamepieces.erase(old_cell)
	
	# TODO: Check for collisions here? Alert one of the two GPs that there's an issue?
	
	_gamepieces[gamepiece.cell] = weakref(gamepiece)


func _on_gamepiece_freed(gamepiece: Gamepiece) -> void:
	if _gamepieces.has(gamepiece.cell):
		_gamepieces.erase(gamepiece.cell)


func _to_string() -> String:
	var msg: = "\nGamepiece Directory:"
	for cell in _gamepieces:
		msg += "\n\t%s at %s" % [_gamepieces[cell].get_ref(), cell]
	return msg
