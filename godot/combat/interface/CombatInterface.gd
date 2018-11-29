extends CanvasLayer

signal action_selected(action)
signal targets_selected(targets)

const CircularMenu = preload("res://combat/interface/circular_menu/CircularMenu.tscn")

onready var lifebar_builder = $BattlersBarsBuilder
onready var select_arrow = $SelectArrow
onready var popup = $PopUpHandler

func initialize(battlers : Array):
	lifebar_builder.initialize(battlers)
	popup.initialize(battlers)

func open_actions_menu(battler : Battler) -> void:
	var actions = battler.actions.get_actions()
	var menu = CircularMenu.instance()
	add_child(menu)
	# TODO: Figure out a way to place the menu above the battler
	menu.rect_position = battler.global_position - Vector2(70.0, 220.0)
	menu.initialize(actions)
	var selected_action : CombatAction = yield(menu, "action_selected")
	emit_signal("action_selected", selected_action)

func select_targets(selectable_battlers : Array) -> void:
	var targets : Array = yield(select_arrow.select_targets(selectable_battlers), "completed")
	emit_signal("targets_selected", targets)
