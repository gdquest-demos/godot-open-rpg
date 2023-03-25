## A signal bus to connect distant scenes to various field-exclusive events.
extends Node

signal cell_highlighted(cell: Vector2i)
signal cell_selected(cell: Vector2i)

signal gamepiece_initialized(gamepiece: Gamepiece)
