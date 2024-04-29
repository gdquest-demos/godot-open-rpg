## A signal bus to connect distant scenes to various combat-exclusive events.
extends Node

## Emitted whenever a combat is triggered. Technically, this event occurs within the field state.
signal combat_initiated(arena: PackedScene)

## Emitted immediately after the player has won combat and all animations have finished.
## This is used to transition to the combat results screen and notify the combat-starting-trigger
## of the combat result.
signal combat_won

## Emitted immediately after the player has lost combat and all animations have finished.
## This is used to fade the screen post-combat and notify the combat-starting-trigger of the result.
signal combat_lost

## Emitted whenever the player has finished with the combat state regardless of whether or not the
## combat was won by the player.
## If the player won the combat, the battle results screen has been displayed and dismissed and the
## screen has faded to black.
## If the player lost combat, the screen has faded to black. In most places, the "gameover" screen
## will be displayed next.
signal combat_finished
