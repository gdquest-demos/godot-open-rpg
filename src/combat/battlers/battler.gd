class_name Battler extends Node2D

## Emitted when the battler finished their action and arrived back at their rest position.
signal action_finished

## Forwarded from the receiving of [signal BettlerStats.health_depleted].
signal health_depleted

## Emitted when taking damage or being healed from a [BattlerHit].
## [br][br]Note the difference between this and [signal BattlerStats.health_changed]:
## 'hit_received' is always the direct result of an action, requiring graphical feedback.
signal hit_received(value: int)

## Emitted whenever a hit targeting this battler misses.
signal hit_missed

## Emitted when the battler's `_readiness` changes.
signal readiness_changed(new_value)

## Emitted when the battler is ready to take a turn.
signal ready_to_act

## Emitted when modifying `is_selected`. The user interface will react to this for
## player-controlled battlers.
signal selection_toggled(value: bool)

@export var stats: BattlerStats = null

# Each action's data stored in this array represents an action the battler can perform.
# These can be anything: attacks, healing spells, etc.
@export var actions: Array[BattlerAction]

# If the battler has an `ai_scene`, we will instantiate it and let the AI make decisions.
# If not, the player controls this battler. The system should allow for ally AIs.
@export var ai_scene: PackedScene

@export var is_player: = false

var is_active: bool = true:
	set(value):
		is_active = value
		set_process(is_active)

# The turn queue will change this property when another battler is acting.
var time_scale := 1.0:
	set(value):
		time_scale = value

# If `true`, the battler is selected, which makes it move forward.
var is_selected: bool = false:
	set(value):
		if value:
			assert(is_selectable)
			
		is_selected = value
		selection_toggled.emit(is_selected)

# If `false`, the battler cannot be targeted by any action.
var is_selectable: bool = true:
	set(value):
		is_selectable = value
		if not is_selectable:
			is_selected = false

# When this value reaches `100.0`, the battler is ready to take their turn.
var readiness := 0.0: 
	set(value):
		readiness = value
		readiness_changed.emit(readiness)
		
		if readiness >= 100.0:
			ready_to_act.emit()
			set_process(false)


func _ready() -> void:
	assert(stats, "Battler %s does not have stats assigned!" % name)
	
	# Resources are NOT unique, so treat the currently assigned BattlerStats as a prototype.
	# That is, copy what it is now and use the copy, so that the original remains unaltered.
	stats = stats.duplicate()
	stats.initialize()
	stats.health_depleted.connect(_on_stats_health_depleted)


func _process(delta: float) -> void:
	readiness += stats.speed * delta * time_scale


func act(action: BattlerAction, targets: Array[Battler] = []) -> void:
	stats.energy -= action.energy_cost
	
	# action.execute() almost certainly is a coroutine.
	@warning_ignore("redundant_await")
	await action.execute(self, targets)
	
	readiness = action.readiness_saved
	
	if is_active:
		set_process(true)
	
	action_finished.emit()


func take_hit(hit: BattlerHit) -> void:
	if hit.is_successful():
		hit_received.emit(hit.damage)
		stats.health -= hit.damage
	
	else:
		hit_missed.emit()


# Returns `true` if the battler is controlled by the player.
func is_player_controlled() -> bool:
	return is_player


func _on_stats_health_depleted() -> void:
	is_active = false
	
	# When opponents die, they're dead, dead, dead. Players may still be brought back, however.
	#if not is_player:
	is_selectable = false
	
	health_depleted.emit()
