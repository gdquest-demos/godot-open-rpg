extends CanvasLayer

<<<<<<< HEAD
signal action_selected(action)
signal targets_selected(targets)
=======
onready var lifebar_builder = $BattlersBarsBuilder
onready var select_arrow = $SelectArrow
onready var action_list = $OldSchoolUI/Row/MonstersPanel/ActionSelector/ItemList
onready var popup = $PopUp
>>>>>>> [WIP] Added Popup information with font.

const CircularMenu = preload("res://combat/interface/circular_menu/CircularMenu.tscn")

onready var lifebar_builder = $BattlersBarsBuilder
onready var select_arrow = $SelectArrow

func initialize(battlers : Array):
	lifebar_builder.initialize(battlers)
<<<<<<< HEAD
=======
	popup.initialize(battlers)
	action_list.hide()

func select_target(selectable_battlers : Array) -> Battler:
	var selected_target : Battler = yield(select_arrow.select_target(selectable_battlers), "completed")
	return selected_target
>>>>>>> [WIP] Added Popup information with font.

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
