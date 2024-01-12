## A screen transition that may [method ScreenTransition.cover] or [method ScreenTransition.reveal]
## the screen based on a texture's alpha channel, rather than as a uniform fade.
class_name TextureScreenTransition extends ScreenTransition

## The shader used to cover or reveal the screen based on a texture.
const TRANSITION_SHADER: = preload("res://src/common/screen_transitions/texture_fade.gdshader")

## The texture used to cover or reveal the screen, usually as a greyscale image. Note that the
## texture's red channel is sampled when determining whether or not a fragment is to be covered.
@export var overlay_texture: Texture:
	set(value):
		overlay_texture = value
		
		if material:
			material.set_shader_parameter("fade_texture", overlay_texture)

# An inverted transition will run in the opposite direction (i.e. from dark to light versus light to
# dark).
var _invert: bool:
	set(value):
		_invert = value
		
		if material:
			material.set_shader_parameter("invert", _invert)


func _ready() -> void:
	super._ready()
	modulate.a = 1.0
	
	material = ShaderMaterial.new()
	material.shader = TRANSITION_SHADER
	material.set_shader_parameter("fade_texture", overlay_texture)


func _tween_transition(duration: float, target_colour: Color) -> void:
	material.set_shader_parameter("progress", 0.0)
	_invert = (target_colour == CLEAR)
	
	_tween = create_tween()
	_tween.tween_property(material, "shader_parameter/progress", 1.0, duration)
	_tween.tween_callback(func(): finished.emit())
