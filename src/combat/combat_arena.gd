## An arena is the background for a battle. It is a Control node that contains the battlers and the turn queue.
## It also contains the music that plays during the battle.
class_name CombatArena extends Control

## The music that will be automatically played during this combat instance.
@export var music: AudioStream

# Keep a reference to the turn queue, which handles combat logic including combat start and end.
@onready var turn_queue: = $Battlers as ActiveTurnQueue

# UI elements
@onready var _ui_animation: = $UI/AnimationPlayer as AnimationPlayer
@onready var _ui_turn_bar: = $UI/TurnBar as UITurnBar
@onready var _ui_effect_label_builder: = $UI/EffectLabelBuilder as UIEffectLabelBuilder
@onready var _ui_player_menus: = $UI/PlayerMenus as UICombatMenus


func _ready() -> void:
	# Setup the different combat UI elements, beginning with the player battler list.
	var combat_participant_data: = turn_queue.battlers
	_ui_effect_label_builder.setup(combat_participant_data)
	_ui_player_menus.setup(combat_participant_data)
	_ui_turn_bar.setup(combat_participant_data)
	
	# The UI elements will automatically fade out once one of the battler teams has lost.
	combat_participant_data.battlers_downed.connect(_ui_turn_bar.fade_out)


## Begin combat, setting up the UI before running combat logic.
func start() -> void:
	# Smoothly fade in the UI elements.
	_ui_animation.play("fade_in")
	await _ui_animation.animation_finished
	
	# Begin the combat logic.
	turn_queue.is_active = true
