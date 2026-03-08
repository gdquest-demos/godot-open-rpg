## An entry in the [UIPlayerBattlerList] for one of the player's [Battler]s.
class_name UIBattlerEntry extends TextureRect

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
			func _on_battler_health_changed(): _life.target_value = battler.stats.health)

@onready var _energy: = $VBoxContainer/CenterContainer/EnergyBar as UIBattlerEnergyBar
@onready var _life: = $VBoxContainer/LifeBar as UIBattlerLifeBar


func _ready() -> void:
	CombatEvents.player_battler_selected.connect(
		func _on_player_battler_selected(selected: Battler) -> void:
			_life.is_highlighted = battler == selected
	)
