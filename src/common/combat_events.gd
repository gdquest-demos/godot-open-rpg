## A signal bus to connect distant scenes to various combat-exclusive events.
extends Node

## Emitted whenever a combat is triggered. Technically, this event occurs within the field state.
signal combat_initiated(arena: PackedScene)
