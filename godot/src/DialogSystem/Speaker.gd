extends TextureRect


func _ready() -> void:
	texture = null


func setup(t: Texture) -> void:
	texture = t