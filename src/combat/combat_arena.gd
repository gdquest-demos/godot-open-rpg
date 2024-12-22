## An arena is the background for a battle. It is a Control node that contains the battlers and the turn queue.
## It also contains the music that plays during the battle.
class_name CombatArena extends Control

@export var music: AudioStream

@onready var battler_list: = $UI/PlayerBattlerList as UIPlayerBattlerList
@onready var turn_queue: = $Battlers as ActiveTurnQueue
@onready var turn_bar: = $UI/TurnBar as UITurnBar
@onready var effect_label_builder: = $UI/EffectLabelBuilder as UIEffectLabelBuilder
@onready var ui_timer: = $UI/Timer as Timer


func _ready() -> void:
	# Setup the player battler list.
	# This is done by filtering the full battler list for only those that belong to the player.
	battler_list.battlers = turn_queue.get_battlers().filter(func(i): return i.is_player)
	
	effect_label_builder.setup(turn_queue.get_battlers())
	turn_bar.setup(turn_queue.get_battlers())
	
	turn_queue.battlers_downed.connect(turn_bar.fade_out)
	turn_queue.battlers_downed.connect(battler_list.fade_out)


## Begin combat, setting up the UI before running combat logic.
func start() -> void:
	# Note that ALL combat UI elements could fade in here. However...
	turn_bar.fade_in()
	
	# ...slightly staggering the UI elements' fade-in creates a nice visual effect.
	ui_timer.start(0.2)
	await ui_timer.timeout

	await battler_list.fade_in()
	
	# Once the UI elements have been setup, pause slightly before beginning combat logic.
	# This gives the player a short moment to get their bearings before combat begins.
	ui_timer.start(0.5)
	await ui_timer.timeout
	turn_queue.is_active = true
