// The following shader is from SlinaDev's Scene Transitions tutorial, accessed from
// https://selinadev.github.io/02-scene-transitions/ on 23.12.2023.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D fade_texture;
uniform float progress: hint_range(0.0, 1.0) = 0.0;
uniform bool invert = false;

void fragment() {
	// Read the red channel from the fade texture. The textures we'll use are greyscale, so using
	// red is arbitrary.
	// This value will be compared to progress to determine when this portion of the screen should
	// be covered.
	float fade_value = texture(fade_texture, UV).r;
	
	// Calculate how opaque the texture should be at a given fragment.
	// TNote that invert-based logical branches can be skipped by converting invert into a float,
	// which will be either one or zero depending on its value.
	COLOR.a = float(fade_value <= progress) * float(!invert) + 
		float(fade_value > progress) * float(invert);
}