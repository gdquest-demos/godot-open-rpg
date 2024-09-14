## An arena is the background for a battle. It is a Control node that contains the battlers and the turn queue.
## It also contains the music that plays during the battle.
class_name CombatArena extends Control

@export var music: AudioStream

@onready var turn_queue: ActiveTurnQueue = $Battlers
@onready var ui_turn_bar: UITurnBar = $UI/TurnBar as UITurnBar
@onready var effect_label_builder: UIEffectLabelBuilder = $UI/EffectLabelBuilder


func _ready() -> void:
	effect_label_builder.setup(turn_queue.get_battlers())
	ui_turn_bar.setup(turn_queue.get_battlers())
	
	turn_queue.battlers_downed.connect(ui_turn_bar.fade_out)
