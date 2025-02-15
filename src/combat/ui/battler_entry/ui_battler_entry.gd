## An entry in the [UIPlayerBattlerList] for one of the player's [Battler]s.
class_name UIBattlerEntry extends TextureButton

## Setup the entry UI values and connect to different changes in [BattlerStats] that the UI will
## measure.
var battler: Battler:
	set(value):
		battler = value
		
		if not is_inside_tree():
			await ready
		
		_energy.setup(battler.stats.max_energy, battler.stats.energy)
		_life.setup(battler.name, battler.stats.max_health, battler.stats.health)
		
		battler.stats.energy_changed.connect(
			func _on_battler_energy_changed(): _energy.value = battler.stats.energy)
		battler.stats.health_changed.connect(
			func _on_battler_health_changed(): 
				_life.target_value = battler.stats.health
				disabled = battler.stats.health <= 0
				
				# If the Battler has been downed, it no longer has a chached action so the preview
				# can be removed.
				if disabled:
					_life.set_action_icon(null)
		)
		
		# Once the player has started to act, remove the action preview icon. The icon only exists
		# to help the player with their battlefield strategy.
		battler.ready_to_act.connect(
			func _on_battler_ready_to_act() -> void:
				_life.set_action_icon(null)
		)

@onready var _energy: = $VBoxContainer/CenterContainer/EnergyBar as UIBattlerEnergyBar
@onready var _life: = $VBoxContainer/LifeBar as UIBattlerLifeBar


func _ready() -> void:
	# If the player queues an action for this Battler, display the queued action's icon next to the
	# Battler name and health points information.
	CombatEvents.action_selected.connect(
		func _on_battler_action_selected(action: BattlerAction, source: Battler, 
				_targets: Array[Battler]) -> void:
			if source == battler:
				if action:
					_life.set_action_icon(action.icon)
				
				else:
					_life.set_action_icon(null)
	)
