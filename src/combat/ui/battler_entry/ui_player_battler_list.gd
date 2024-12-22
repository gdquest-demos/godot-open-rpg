class_name UIPlayerBattlerList extends UIListMenu

## The battler list will create individual entries for each [Battler] contained in this array.
## The entries are created when the member is assigned and the list is [signal ready].
@export var battlers: Array[Battler]:
	set(value):
		battlers = value
		
		if not is_inside_tree():
			await ready
		
		# Free any old entries, if they exist.
		for child in get_children():
			if child is UIBattlerEntry:
				child.queue_free()
		
		# Create a UI entry for each battler in the party.
		for battler in battlers:
			var new_entry = _create_entry() as UIBattlerEntry
			new_entry.setup(battler)
		
		fade_in()


## Override the base method to let the combat know which battler was selected.
func _on_entry_pressed(entry: BaseButton) -> void:
	if not is_disabled:
		var battler_entry = entry as UIBattlerEntry
		print(battler_entry)
		
		fade_out()
