## An arena is the background for a battle. It is a Control node that contains the battlers and the turn queue.
## It also contains the music that plays during the battle.
class_name CombatArena extends Control

## The music that will be automatically played during this combat instance.
@export var music: AudioStream

# Keep a reference to the turn queue, which handles combat logic including combat start and end.
@onready var turn_queue: = $Battlers as ActiveTurnQueue

# The timer provides margin around combat events (such as start/end). This allows the player to get
# their bearings on combat start or provide a 'breather' before combat resolution screens.
@onready var _timer: = $UI/Timer as Timer

# UI elements
@onready var _ui_action_ui_builder: = $UI/PlayerActionUIBuilder as UIActionMenuBuilder
@onready var _ui_battler_list: = $UI/PlayerBattlerList as UIPlayerBattlerList
@onready var _ui_turn_bar: = $UI/TurnBar as UITurnBar
@onready var _ui_effect_label_builder: = $UI/EffectLabelBuilder as UIEffectLabelBuilder


func _ready() -> void:
	# Setup the different combat UI elements, beginning with the player battler list.
	var combat_participant_data: = turn_queue.battlers
	_ui_action_ui_builder.setup(combat_participant_data)
	_ui_battler_list.setup(combat_participant_data)
	_ui_effect_label_builder.setup(combat_participant_data)
	_ui_turn_bar.setup(combat_participant_data)
	
	# The UI elements will automatically fade out once one of the battler teams has lost.
	combat_participant_data.battlers_downed.connect(_ui_turn_bar.fade_out)
	combat_participant_data.battlers_downed.connect(_ui_battler_list.fade_out)


## Begin combat, setting up the UI before running combat logic.
func start() -> void:
	# Note that ALL combat UI elements could fade in here. However...
	_ui_turn_bar.fade_in()
	
	# ...slightly staggering the UI elements' fade-in creates a nice visual effect.
	_timer.start(0.2)
	await _timer.timeout

	await _ui_battler_list.fade_in()
	
	# Once the UI elements have been setup, pause slightly before beginning combat logic.
	# This gives the player a short moment to get their bearings before combat begins.
	_timer.start(0.5)
	await _timer.timeout
	turn_queue.is_active = true
