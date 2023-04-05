## Highlight only the focused cell under cursor events.
class_name CursorHighlightDefault
extends CursorHighlightStrategy


func highlight(tilemap: TileMap, focus: Vector2i) -> void:
	if focus == Grid.INVALID_CELL:
		return
	
	tilemap.set_cell(FieldCursor.CURSOR_LAYER, focus, 0, FieldCursor.CURSOR_TYPE.Default)
