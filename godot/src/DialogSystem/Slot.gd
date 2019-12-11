extends TextureRect


const COLORS : = {
	active = Color("ffffff"),
	inactive = Color("646464")
}


func _ready() -> void:
	texture = null


func setup(t: Texture) -> void:
	texture = t
	anchor_top = ANCHOR_END
	anchor_bottom = ANCHOR_END
	margin_bottom = 0
	margin_top = -texture.get_height()