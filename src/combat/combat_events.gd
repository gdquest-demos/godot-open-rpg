## A signal bus to connect distant scenes to various combat-exclusive events.
extends Node

## Emitted whenever a player battler is selected, prompting the player to choose an action.
@warning_ignore("unused_signal")
signal player_battler_selected(battler: Battler)

## Keep track of the arena used for the current combat.
## This value is used to pass an arena to the Combat state and will be null otherwise.
var current_arena: PackedScene
