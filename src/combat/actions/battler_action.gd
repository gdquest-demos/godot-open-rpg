## Discrete actions that a [Battler] may take on its turn.
##
## The following class is an interface that specific actions should implement. [method execute] is
## called once an action has been chosen and is a coroutine, containing the logic of the action
## including any animations or effects.
class_name BattlerAction extends Resource

## An action-specific icon. Shown primarily in menus.
@export var icon: Texture
## The 'name' of the action. Shown primarily in menus.
@export var label: = "Base combat action"
## Tells the player exactly what an action does. Shown primarily in menus.
@export var description: = "A combat action."
## Amount of energy required to perform the action.
@export_range(0, 10) var energy_cost: = 0
## The action's [enum Elements.Types].
@export var element: = Elements.Types.NONE
@export var targets_self: = false
@export var targets_all: = false
## The amount of [member Battler.readiness] left to the Battler after acting. This can be used to
## design weak attacks that allow the Battler to take fast turns.
@export_range(0.0, 100.0) var readiness_saved: = 0.0


## Returns true if the [Battler] is able to use the action.
func can_be_used_by(battler: Battler) -> bool:
	return energy_cost <= battler.stats.energy


## The body of the action, where different animations/modifiers/damage/etc. will be played out.
## Battler actions are (almost?) always coroutines, so it is expected that the caller will wait for
## execution to finish.
## [br][br]Note: The base action class does nothing, but must be overridden to do anything.
func execute(source: Battler, _targets: Array[Battler] = []) -> void:
	await source.get_tree().process_frame
