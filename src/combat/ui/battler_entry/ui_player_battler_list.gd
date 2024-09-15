class_name UIPlayerBattlerList extends VBoxContainer

const ENTRY_SCENE: = preload("res://src/combat/ui/battler_entry/ui_battler_entry.tscn")

@onready var _anim: = $AnimationPlayer as AnimationPlayer


## Creates a battler UI entry for each battler in the party.
func setup(battlers: Array[Battler]) -> void:
	for battler in battlers:
		var battler_hud: = ENTRY_SCENE.instantiate()
		add_child(battler_hud)
		battler_hud.setup(battler)


## Fades in the battler list.
func fade_in() -> void:
	_anim.play("fade_in")
	await _anim.animation_finished


## Fades out the battler list.
func fade_out() -> void:
	_anim.play("fade_out")
	await _anim.animation_finished
