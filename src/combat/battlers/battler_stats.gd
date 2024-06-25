class_name BattlerStats extends Resource

## A list of all properties that can receive bonuses.
const MODIFIABLE_STATS = [
	"max_health", "max_energy", "attack", "defense", "speed", "hit_chance", "evasion"
]

## Emitted when [member health] has reached 0.
signal health_depleted

## Emitted whenever [member health] changes.
signal health_changed(old_value, new_value)

## Emitted whenver [member energy] changes.
signal energy_changed(old_value, new_value)

# The property below stores a list of modifiers for each property listed in MODIFIABLE_STATS.
# Dictionary keys are the name of the property (String).
# Dictionary values are another dictionary, with uid/modifier pairs.
var _modifiers := {}

@export var base_max_health: = 100
@export var base_max_energy: = 6

@export var base_attack: = 10.0:
	set(value):
		base_attack = value
		_recalculate_and_update("attack")

@export var base_defense: = 10.0:
	set(value):
		base_defense = value
		_recalculate_and_update("defense")

@export var base_speed: = 70.0:
	set(value):
		base_speed = value
		_recalculate_and_update("speed")

@export var base_hit_chance: = 100.0:
	set(value):
		base_hit_chance = value
		_recalculate_and_update("hit_chance")

@export var base_evasion: = 0.0:
	set(value):
		base_evasion = value
		_recalculate_and_update("evasion")

var max_health: = base_max_health
var max_energy: = base_max_energy
var attack: = base_attack
var defense: = base_defense
var speed: = base_speed
var hit_chance: = base_hit_chance
var evasion: = base_evasion

var health: = max_health:
	set(value):
		if value != health:
			var previous_health: = health
			health = clampi(value, 0, max_health)
			
			health_changed.emit(previous_health, health)
			if health == 0:
				health_depleted.emit()

var energy: = 0:
	set(value):
		if value != energy:
			var previous_energy = energy
			energy = clampi(value, 0, max_energy)
			
			energy_changed.emit(previous_energy, energy)


func _init() -> void:
	for prop_name in MODIFIABLE_STATS:
		_modifiers[prop_name] = {}


func initialize() -> void:
	health = max_health


# Adds a modifier that affects the stat with the given `stat_name` and returns its unique id.
func add_modifier(stat_name: String, value: float) -> int:
	assert(stat_name in MODIFIABLE_STATS, "Trying to add a modifier to a nonexistent stat.")

	var id: = _generate_unique_id(stat_name)
	_modifiers[stat_name][id] = value
	_recalculate_and_update(stat_name)
	
	# Returning the id allows the caller to bind it to a signal. For instance
	# with equpment, to call `remove_modifier()` upon removing the equipment.
	return id


# Removes a modifier associated with the given `stat_name`.
func remove_modifier(stat_name: String, id: int) -> void:
	assert(id in _modifiers[stat_name], "Stat %s does not have a modifier with ID '%s'." % [id, 
		_modifiers[stat_name]])
	
	_modifiers[stat_name].erase(id)
	_recalculate_and_update(stat_name)


# Calculates the final value of a single stat. That is, its based value with all modifiers applied.
# We reference a stat property name using a string here and update it with the `set()` method.
func _recalculate_and_update(prop_name: String) -> void:
	assert(get(prop_name), "Cannot update battler stat '%s'! Stat name is invalid!" % prop_name)
	
	# All our property names follow a pattern: the base stat has the same identifier as the final 
	# stat with the "base_" prefix.
	var value = get("base_" + prop_name)
	assert(value, "Cannot update battler stat %s! Stat does not have base value!" % prop_name)
	
	var modifiers: Array = _modifiers[prop_name].values()
	for modifier in modifiers:
		value += modifier
	if value < 0:
		value = 0
	
	# Here's where we assign the value to the stat. For instance, if the `stat` argument is 
	# "attack", this is like writing 'attack = value'.
	set(prop_name, value)


# Find the first unused integer in a stat's modifiers keys.
func _generate_unique_id(stat_name: String) -> int:
	# If there are no keys, we return `0`, which is our first valid unique id. Without existing 
	# keys, calling methods like `Array.back()` will trigger an error.
	var keys: Array = _modifiers[stat_name].keys()
	if keys.is_empty():
		return 0
	
	else:
		# We always start from the last key, which will always be the highest number, even if we 
		# remove modifiers.
		return keys.back() + 1
