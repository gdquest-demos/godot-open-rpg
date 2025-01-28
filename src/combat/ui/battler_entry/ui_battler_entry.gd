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
		)

@onready var _energy: = $HBoxContainer/CenterContainer/EnergyBar as UIBattlerEnergyBar
@onready var _life: = $HBoxContainer/LifeBar as UIBattlerLifeBar
