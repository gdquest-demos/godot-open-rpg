## A signal bus to connect distant scenes to various field-exclusive events.
extends Node

## Set this object's process priority to a very high number.
## We want the Field Event manager's _process method to run after all Gamepieces and Controllers.
const PROCESS_PRIORITY: = 99999999

## Emitted when the cursor moves to a new position on the field gameboard.
@warning_ignore("unused_signal")
signal cell_highlighted(cell: Vector2i)

## Emitted when the player selects a cell on the field gameboard via the [FieldCursor].
@warning_ignore("unused_signal")
signal cell_selected(cell: Vector2i)

## Emitted whenever a combat is triggered. This will lead to a transition from the field 'state' to
## a combat 'state'.
@warning_ignore("unused_signal")
signal combat_triggered(arena: PackedScene)

## Emitted when a [Cutscene] begins, signalling that the player should yield control of their
## character to the cutscene code.
@warning_ignore("unused_signal")
signal cutscene_began

## Emitted when a [Cutscene] ends, restoring normal mode of play.
@warning_ignore("unused_signal")
signal cutscene_ended

## Gamepiece related signals, usually emitted by the the gamepieces themselves.
signal gamepiece_cell_changed(gamepiece: Gamepiece, old_cell: Vector2i)

## Emitted when the player sets a movement path for their focused gamepiece.
## The destination is the last cell in the path.
@warning_ignore("unused_signal")
signal player_path_set(gamepiece: Gamepiece, destination_cell: Vector2i)

## Emitted whenever terrain passability changes. Pathfinders will need to be rebuilt.
@warning_ignore("unused_signal")
signal terrain_changed

## Emitted whenever ALL input within the field state is to be paused or resumed.
## Typically emitted by combat, dialogues, etc.
@warning_ignore("unused_signal")
signal input_paused(is_paused: bool)

# The physics engine updates a frame after physics object move, which plays havoc with our
# CollisionFinder class (objects are not there the same frame they move!).
# This is an issue for moving gamepices. Multiple Gamepieces may decide to move onto the same cell
# in the same frame, since their collision shapes will not yet be blocking the cell.
# The Field Events manager keeps track of these edge cases by recording which cells were targeted
# for movement THIS FRAME. The record will be cleared at the end of the frame and wait for other
# cell_changed signals.
# Please note that this is not a comprehensive list of moving gamepieces, but rather a list of
# changes in cells that occured from Gamepieces for this frame only.
var _cell_changes_this_frame: Array[Vector2i] = []


func _ready() -> void:
	gamepiece_cell_changed.connect(_on_gamepiece_cell_changed)
	
	# We want to clear the record of this frame's cell changes at the end of the frame, so this
	# class's _process() should run last.
	set_process_priority(PROCESS_PRIORITY)


func _process(_delta: float) -> void:
	_cell_changes_this_frame.clear()


func did_gp_move_to_cell_this_frame(cell: Vector2i) -> bool:
	return _cell_changes_this_frame.has(cell)


func _on_gamepiece_cell_changed(gamepiece: Gamepiece, _old_cell: Vector2i) -> void:
	_cell_changes_this_frame.append(gamepiece.cell)
