## An arena is the editor-configured environment for a battle. It is a Control node that contains 
## the combat participants and details (such as background, foreground, music, etc.).
class_name CombatArena extends Control

## The music that will be automatically played during this combat instance.
@export var music: AudioStream

## The [Cutscene] to run in the field state if this combat is won by the player.
## Note that an empty value will simply return control to the player afterwards.
@export var victory_cutscene: String

## The [Cutscene] to run in the field state if this combat is lost by the player.
## Note that an empty value will simply return control to the player afterwards.
@export var loss_cutscene: String

## Retrieve the list of the combat participants, in [BattlerRoster] form.
func get_battler_roster() -> BattlerRoster:
	return $Battlers as BattlerRoster
