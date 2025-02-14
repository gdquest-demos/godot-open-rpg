## Discrete actions that a [Battler] may take on its turn.
##
## The following class is an interface that specific actions should implement. [method execute] is
## called once an action has been chosen and is a coroutine, containing the logic of the action
## including any animations or effects.
class_name BattlerAction extends Resource

enum TargetScope { SELF, SINGLE, ALL }

@export_group("UI")
## An action-specific icon. Shown primarily in menus.
@export var icon: Texture
## The 'name' of the action. Shown primarily in menus.
@export var label: = "Base combat action"
## Tells the player exactly what an action does. Shown primarily in menus.
@export var description: = "A combat action."

# Action targeting properties.
@export_group("Targets")
## Determines how many [Battler]s this action targets. [b]Note:[/b] [enum TargetScope.SELF] will not
## make use of the [targets_friendlies] or [targets_enemies] flags.
@export var target_scope: = TargetScope.SINGLE
## Can this action target friendly [Battler]s? Has no effect if [target_scope] is
## [enum TargetScope.SELF].
@export var targets_friendlies: = false
## Can this action target enemy [Battler]s? Has no effect if [target_scope] is
## [enum TargetScope.SELF].
@export var targets_enemies: = false

@export_group("")

## The action's [enum Elements.Types].
@export var element: = Elements.Types.NONE

## Amount of energy required to perform the action.
@export_range(0, 10) var energy_cost: = 0

## The amount of [member Battler.readiness] left to the Battler after acting. This can be used to
## design weak attacks that allow the Battler to take fast turns.
@export_range(0.0, 100.0) var readiness_saved: = 0.0


### Returns true if the [Battler] is able to use the action.
### [br][br]By default, this method checks for a few conditions:
###    - The battler reference is valid.
###    - The battler has health points.
###    - The battler has enough action points to perform the action.
#func can_be_used_by(battler: Battler) -> bool:
	#return battler != null \
		#and battler.stats.health > 0 \
		#and battler.stats.energy >= energy_cost


## Verifies that an action can be run. This can be dependent on any number of details regarding the
## source and target [Battler]s.
func can_execute(source: Battler, targets: Array[Battler] = []) -> bool:
	if source == null \
			or source.stats.health <= 0 \
			or source.stats.energy < energy_cost:
		return false
	
	return !targets.is_empty()


## Evaluate whether or not a given target is valid for this action, irrespective of the battler's
## team (player or enemy).[br][br]
## [b]For example:[/b] a resurrection spell will target only dead battlers, looking for battlers
## with [member BattlerStates.health] that is not greater than zero. Most actions, on the other
## hand, will want targets that are selectable and have health points greater than zero.
func is_target_valid(target: Battler) -> bool:
	if target.is_selectable and target.stats.health > 0:
		return true
	return false

## The body of the action, where different animations/modifiers/damage/etc. will be played out.
## Battler actions are (almost?) always coroutines, so it is expected that the caller will wait for
## execution to finish.
## [br][br]Note: The base action class does nothing, but must be overridden to do anything.
func execute(source: Battler, _targets: Array[Battler] = []) -> void:
	await source.get_tree().process_frame


## Returns and array of [Battler]s that could be affected by the action.
## This includes most cases, accounting for parameters such as [member targets_self]. Specific
## actions may wish to override get_possible_targets (to target only mushrooms, for example).
func get_possible_targets(source: Battler, battlers: BattlerList) -> Array[Battler]:
	var possible_targets: Array[Battler] = []
	
	# Normally, actions can pick from battlers of the opposing team. However, actions may be
	# specified to target the source battler only or to target ALL battlers instead.
	if target_scope == TargetScope.SELF:
		possible_targets.append(source)
	
	elif source.is_player:
		if targets_friendlies:
			possible_targets.append_array(battlers.players)
		
		if targets_enemies:
			possible_targets.append_array(battlers.enemies)
	
	else:
		if targets_friendlies:
			possible_targets.append_array(battlers.enemies)
		
		elif targets_enemies:
			possible_targets.append_array(battlers.players)
	
	# Filter the targets to only include live Battlers.
	possible_targets = battlers.get_live_battlers(possible_targets)
	return possible_targets


func can_target_battler(target: Battler) -> bool:
	if target.is_selectable and target.stats.health > 0:
		return true
	return false


func targets_all() -> bool:
	return target_scope == TargetScope.ALL
