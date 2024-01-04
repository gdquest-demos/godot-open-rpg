class_name TextureScreenTransition extends ScreenTransition

const TRANSITION_SHADER: = preload("res://src/common/screen_transitions/texture_fade.gdshader")

@export var overlay_texture: Texture:
	set(value):
		overlay_texture = value
		
		if material:
			material.set_shader_parameter("fade_texture", overlay_texture)
		
@export var invert: bool:
	set(value):
		invert = value
		
		if material:
			material.set_shader_parameter("invert", invert)


func _ready() -> void:
	super._ready()
	modulate.a = 1.0
	
	material = ShaderMaterial.new()
	material.shader = TRANSITION_SHADER
	material.set_shader_parameter("fade_texture", overlay_texture)


func _tween_transition(duration: float, target_colour: Color) -> void:
	material.set_shader_parameter("progress", 0.0)
	invert = (target_colour == CLEAR)
	
	_tween = create_tween()
	_tween.tween_property(material, "shader_parameter/progress", 1.0, duration)
	_tween.tween_callback(func(): finished.emit())
