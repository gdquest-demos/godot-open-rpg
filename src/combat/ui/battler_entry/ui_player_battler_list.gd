## The player battler UI displays information for each player-owned [Battler] in a combat.
## These entries may be selected in order to queue actions for the battlers to perform.
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
			new_entry.battler = battler
		
		_loop_first_and_last_entries()
		
		fade_in()


func _ready() -> void:
	# If the player has selected a battler, prevent input from reaching the battler list.
	# This is relevant with mouse/touchscreen input.
	# If the player has finished navigating the menu, restore input to the battler list.
	CombatEvents.player_battler_selected.connect(
		func _on_player_battler_selected(battler: Battler):
			is_disabled = battler != null
			
			# Don't re-enable entries that have dead Battlers.
			if not is_disabled:
				for entry: UIBattlerEntry in _entries:
					if entry.battler.stats.health <= 0:
						entry.disabled = true
	)


## Create all menu entries needed to track player battlers throughout the combat.
func setup(battler_data: BattlerList) -> void:
	battlers = battler_data.players


# Override the base method to let the combat know which battler was selected.
func _on_entry_pressed(entry: BaseButton) -> void:
	if not is_disabled:
		var battler_entry = entry as UIBattlerEntry
		
		# Prevent the player from issuing orders to AI-controlled Battlers.
		if not battler_entry.battler.ai_scene:
			CombatEvents.player_battler_selected.emit(battler_entry.battler)
