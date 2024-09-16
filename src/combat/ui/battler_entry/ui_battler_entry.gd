class_name UIBattlerEntry extends TextureRect

@onready var _energy: = $HBoxContainer/CenterContainer/EnergyBar as UIBattlerEnergyBar
@onready var _life: = $HBoxContainer/LifeBar as UIBattlerLifeBar


func setup(battler: Battler) -> void:
	_energy.setup(battler.stats.max_energy, battler.stats.energy)
	_life.setup(battler.name, battler.stats.max_health, battler.stats.health)
	
	battler.stats.energy_changed.connect(_on_energy_changed.bind(battler.stats))
	battler.stats.health_changed.connect(_on_health_changed.bind(battler.stats))


func _on_energy_changed(stats: BattlerStats) -> void:
	_energy.value = stats.energy


func _on_health_changed(stats: BattlerStats) -> void:
	_life.target_value = stats.health
