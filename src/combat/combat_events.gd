## A signal bus to connect distant scenes to various combat-exclusive events.
extends Node

## Emitted whenever a combat has been setup and is ready to become the active 'game state'. At this
## point, the screen is fully covered by the [ScreenTransition] autoload.
@warning_ignore("unused_signal")
signal combat_initiated(arena: PackedScene)

## Emitted whenever the player has finished with the combat state regardless of whether or not the
## combat was won by the player. At this point the screen has faded to black and any events that
## immediately follow the combat may occur.
@warning_ignore("unused_signal")
signal combat_finished(is_player_victory: bool)

## Emitted whenever a player battler is selected, prompting the player to choose an action.
@warning_ignore("unused_signal")
signal player_battler_selected(battler: Battler)

## Emitted whenever a player selects an action from the action menu.
@warning_ignore("unused_signal")
signal player_action_selected(action: BattlerAction, possible_targets: Array[Battler])

## Emitted whenever a player selects targets or cancels target selection.
@warning_ignore("unused_signal")
signal player_targets_selected(targets: Array[Battler])

## A variable that allows objects to know if the player won the most recent combat. This should only
## be accessed, and is designed to be set by the combat state.
var did_player_win_last_combat: = false
