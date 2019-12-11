extends HBoxContainer


var value : = 100 setget set_value

var _bar : TextureProgress = null
var _label : Label = null


func set_value(new_value: int) -> void:
	value = new_value
	_bar.value = value
	_label.text = '%d/%d' % [value, _bar.max_value]


func _ready() -> void:
	_bar = $Bar
	_label = $Label