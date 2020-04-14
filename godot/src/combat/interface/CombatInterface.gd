extends CanvasLayer

signal action_selected(action)
signal targets_selected(targets)

const CircularMenu = preload("res://src/combat/interface/circular_menu/CircularMenu.tscn")

onready var lifebar_builder = $BattlersBarsBuilder
onready var popup = $PopUpHandler
onready var select_arrow = $SelectArrow
onready var turn_order = $TurnOrder

export var buttons_offset: Vector2 = Vector2(-75.0, 0.0)


func initialize(combat_arena: CombatArena, turn_queue: TurnQueue, battlers: Array):
	turn_order.initialize(combat_arena, turn_queue)
	lifebar_builder.initialize(battlers)
	popup.initialize(battlers)
	remove_child(select_arrow)


func open_actions_menu(battler: Battler) -> void:
	var menu = CircularMenu.instance()
	add_child(menu)
	var extents: RectExtents = battler.skin.get_extents()
	menu.rect_position = battler.global_position - Vector2(0.0, extents.size.y) + buttons_offset
	menu.initialize(battler)
	menu.open()
	var selected_action: CombatAction = yield(menu, "action_selected")
	emit_signal("action_selected", selected_action)


func select_targets(selectable_battlers: Array) -> void:
	add_child(select_arrow)
	var targets: Array = yield(select_arrow.select_targets(selectable_battlers), "completed")
	emit_signal("targets_selected", targets)
	remove_child(select_arrow)
