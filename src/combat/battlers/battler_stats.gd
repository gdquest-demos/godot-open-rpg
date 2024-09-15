## Numerically represents the characteristics of a specific [Battler].
class_name BattlerStats extends Resource

## A list of all properties that can receive bonuses.
const MODIFIABLE_STATS = [
	"max_health", "max_energy", "attack", "defense", "speed", "hit_chance", "evasion"
]

## Emitted when [member health] has reached 0.
signal health_depleted
## Emitted whenever [member health] changes.
signal health_changed()
## Emitted whenver [member energy] changes.
signal energy_changed()

@export_category("Elements")
## The battler's elemental affinity. Determines which attacks are more or less effective against
## this battler.
@export var affinity := Elements.Types.NONE

@export_category("Stats")
@export var base_max_health := 100
@export var base_max_energy := 6
@export var base_attack := 10:
	set(value):
		base_attack = value
		_recalculate_and_update("attack")
@export var base_defense := 10:
	set(value):
		base_defense = value
		_recalculate_and_update("defense")
@export var base_speed := 70:
	set(value):
		base_speed = value
		_recalculate_and_update("speed")
@export var base_hit_chance := 100:
	set(value):
		base_hit_chance = value
		_recalculate_and_update("hit_chance")
@export var base_evasion := 0:
	set(value):
		base_evasion = value
		_recalculate_and_update("evasion")

var max_health := base_max_health
var max_energy := base_max_energy
var attack := base_attack
var defense := base_defense
var speed := base_speed
var hit_chance := base_hit_chance
var evasion := base_evasion

var health := max_health:
	set(value):
		if value != health:
			health = clampi(value, 0, max_health)

			health_changed.emit()
			if health == 0:
				health_depleted.emit()

var energy := 0:
	set(value):
		if value != energy:
			energy = clampi(value, 0, max_energy)
			energy_changed.emit()

# The properties below stores a list of modifiers for each property listed in MODIFIABLE_STATS.
# Dictionary keys are the name of the property (String).
# Dictionary values are another dictionary, with uid/modifier pairs.
var _modifiers := {}
var _multipliers := {}


func _init() -> void:
	for prop_name in MODIFIABLE_STATS:
		_modifiers[prop_name] = {}
		_multipliers[prop_name] = {}


func initialize() -> void:
	health = max_health


## Adds a modifier that affects the stat with the given `stat_name` and returns its unique id.
func add_modifier(stat_name: String, value: int) -> int:
	assert(stat_name in MODIFIABLE_STATS, "Trying to add a modifier to a nonexistent stat.")

	var id := _generate_unique_id(stat_name, true)
	_modifiers[stat_name][id] = value
	_recalculate_and_update(stat_name)

	# Returning the id allows the caller to bind it to a signal. For instance
	# with equpment, to call `remove_modifier()` upon removing the equipment.
	return id


## Adds a multiplier that affects the stat with the given `stat_name` and returns its unique id.
func add_multiplier(stat_name: String, value: float) -> int:
	assert(stat_name in MODIFIABLE_STATS, "Trying to add a modifier to a nonexistent stat.")

	var id := _generate_unique_id(stat_name, false)
	_multipliers[stat_name][id] = value
	_recalculate_and_update(stat_name)

	return id


# Removes a modifier associated with the given `stat_name`.
func remove_modifier(stat_name: String, id: int) -> void:
	assert(id in _modifiers[stat_name], "Stat %s does not have a modifier with ID '%s'." % [id,
		_modifiers[stat_name]])

	_modifiers[stat_name].erase(id)
	_recalculate_and_update(stat_name)


func remove_multiplier(stat_name: String, id: int) -> void:
	assert(id in _multipliers[stat_name], "Stat %s does not have a multiplier with ID '%s'." % [id,
		_multipliers[stat_name]])

	_multipliers[stat_name].erase(id)
	_recalculate_and_update(stat_name)


# Calculates the final value of a single stat. That is, its based value with all modifiers applied.
# We reference a stat property name using a string here and update it with the `set()` method.
func _recalculate_and_update(prop_name: String) -> void:
	assert(prop_name in self, "Cannot update battler stat '%s'! Stat name is invalid!" % prop_name)

	# All our property names follow a pattern: the base stat has the same identifier as the final
	# stat with the "base_" prefix.
	var base_prop_id := "base_" + prop_name
	assert(base_prop_id in self, "Cannot update battler stat %s! Stat does not have base value!" % prop_name)
	var value := get(base_prop_id) as float

	# Multipliers apply to the stat multiplicatively.
	# They are first summed, with the sole restriction that they may not go below zero.
	var stat_multiplier := 1.0
	var multipliers: Array = _multipliers[prop_name].values()
	for multiplier in multipliers:
		stat_multiplier += multiplier
	if stat_multiplier < 0.0:
		stat_multiplier = 0.0

	# Apply the cumulative multiplier to the stat.
	if not is_equal_approx(stat_multiplier, 1.0):
		value *= stat_multiplier

	# Add all modifiers to the stat.
	var modifiers: Array = _modifiers[prop_name].values()
	for modifier in modifiers:
		value += modifier

	# Finally, don't allow values to drop below zero.
	value = roundf(max(value, 0.0))

	# Here's where we assign the value to the stat. For instance, if the `stat` argument is
	# "attack", this is like writing 'attack = value'.
	# Note that this sets an integer to a float value, so the decimal will no longer be relevent.
	set(prop_name, value)


# Find the first unused integer in a stat's modifiers keys.
# is_modifier determines whether the id is determined from the modifier or multiplier dictionary.
func _generate_unique_id(stat_name: String, is_modifier := true) -> int:
	# Generate an ID for either modifiers or multipliers.
	var dictionary := _modifiers
	if not is_modifier:
		dictionary = _multipliers

	# If there are no keys, we return `0`, which is our first valid unique id. Without existing
	# keys, calling methods like `Array.back()` will trigger an error.
	var keys: Array = dictionary[stat_name].keys()
	if keys.is_empty():
		return 0
	else:
		# We always start from the last key, which will always be the highest number, even if we
		# remove modifiers.
		return keys.back() + 1
