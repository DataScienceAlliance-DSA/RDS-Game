shader_type canvas_item;

uniform float scrolling_speed = 1.0;
uniform vec4 texture_modulate = vec4(1.,1.,1.,1.);

void fragment() {
	vec2 moving_uv = vec2(UV.x - (TIME*scrolling_speed), UV.y);
	vec4 in_tex = texture(TEXTURE, moving_uv);
	COLOR = in_tex * texture_modulate;
}
