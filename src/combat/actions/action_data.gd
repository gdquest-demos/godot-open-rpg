class_name ActionData extends Resource

enum Elements { NONE, BUG, BREAK, SEEK, VOID, STATIC, CONTROL, GUARD, EXCEPTION }

## An action-specific icon. Shown primarily in menus.
@export var icon: Texture

## The 'name' of the action. Shown primarily in menus.
@export var label: = "Base combat action"

## Tells the player exactly what an action does. Shown primarily in menus.
@export var description: = "A combat action."

## Amount of energy required to perform the action.
@export_range(0, 10) var energy_cost: = 0

## The action's [enum Elements].
@export var element: = Elements.NONE

@export var targets_self: = false
@export var targets_all: = false

## The amount of [member Battler.readiness] left to the Battler after acting. This can be used to
## design weak attacks that allow the Battler to take fast turns.
@export_range(0.0, 100.0) var readiness_saved: = 0.0


## Returns true if the [Battler] is able to use the action.
func can_be_used_by(battler: Battler) -> bool:
	return energy_cost <= battler.stats.energy
