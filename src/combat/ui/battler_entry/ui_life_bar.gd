## An element of the [UIBattlerEntry] that visually shows player [Battler] life points.
##
## The LifeBar also can show an action icon to demonstrate when the player has queued an action for
## one of their Battlers.
class_name UIBattlerLifeBar extends TextureProgressBar

# Rate of the animation relative to `max_value`. A value of 1.0 means the animation fills the entire
# bar in one second.
@export var fill_rate := 0.5

@export_range(0, 1.0) var danger_cutoff: = 0.2

# When this value changes, the bar smoothly animates towards it using a tween.
# See the setter function below for the details.
var target_value := 0.0:
	set(new_value):
		# If the `amount` is lower than the current `target_value`, it means the battler lost 
		# health.
		if target_value > new_value:
			_bar_anim.play("damage")
		
		target_value = new_value
		if _tween:
			_tween.kill()
		
		var duration: float = abs(target_value - value) / max_value * fill_rate
		_tween = create_tween().set_trans(Tween.TRANS_QUAD)
		_tween.tween_property(self, "value", target_value, duration)
		_tween.tween_callback(
			func():
				if value < danger_cutoff * max_value:
					_bar_anim.play("danger")
		)

var is_highlighted: = false:
	set(value):
		is_highlighted = value
		if is_highlighted:
			_text_anim.play("highlighted")
		else:
			_text_anim.play("default")

var _tween: Tween = null

@onready var _bar_anim: = $BarAnimation as AnimationPlayer
@onready var _name_label: = $MarginContainer/HBoxContainer/Name as Label
@onready var _text_anim: = $MarginContainer/HBoxContainer/TextAnimation as AnimationPlayer
@onready var _value_label: = $MarginContainer/HBoxContainer/Value as Label


func _ready() -> void:
	value_changed.connect(
		func _on_value_changed(new_value: float):
			_value_label.text = str(int(new_value))
	)


func setup(battler_name: String, max_hp: int, start_hp: int) -> void:
	_name_label.text = battler_name
	
	max_value = max_hp
	value = start_hp
