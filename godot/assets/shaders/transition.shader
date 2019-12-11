shader_type canvas_item;
render_mode unshaded;

uniform float cutoff : hint_range(0.0, 1.0);
uniform float smooth_size : hint_range(0.0, 1.0);
uniform sampler2D mask : hint_albedo;

void fragment() {
	float alpha = texture(mask, UV).r;
	alpha = smoothstep(cutoff, cutoff + smooth_size, alpha * (1.0 - smooth_size) + smooth_size);
	vec4 color = vec4(clamp(0.5 + 0.65 * UV.x, 0.0, 1.0), 0.55, 0.2, alpha);
	vec4 scr = textureLod(SCREEN_TEXTURE, SCREEN_UV, 2.0 * (1.0 - cutoff));
	scr.rgb = mix(scr.rgb, 1.0 - alpha + scr.rgb, 1.0 - cutoff);
	COLOR = mix(color, scr, cutoff);
}
