## A signal bus to connect distant scenes to various field-exclusive events.
extends Node

## Emitted when the cursor moves to a new position on the field gameboard.
signal cell_highlighted(cell: Vector2i)

# Emitted when the player selects a cell on the field gameboard via the [FieldCursor].
signal cell_selected(cell: Vector2i)

## Emitted when a gamepiece has been initialized and may be registered with different systems.
signal gamepiece_initialized(gamepiece: Gamepiece)
