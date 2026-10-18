## The player battler UI displays information for each player-owned [Battler] in a combat.
## These entries may be selected in order to queue actions for the battlers to perform.
class_name UIPlayerBattlerList extends VBoxContainer

## The scene that represents the player Battlers in menu form.
@export var entry_scene: PackedScene

## The battler list will create individual entries for each [Battler] contained in this array.
## The entries are created when the member is assigned and the list is [signal ready].
@export var battlers: Array[Battler]:
	set(value):
		battlers = value
		if not is_inside_tree():
			await ready
		
		# Create a UI entry for each battler in the party.
		for battler in battlers:
			var new_entry: = entry_scene.instantiate()
			add_child(new_entry)
			_entries.append(new_entry)
			
			new_entry.battler = battler

# Track all battler list entries in the following array. 
var _entries: Array[UIBattlerEntry] = []
