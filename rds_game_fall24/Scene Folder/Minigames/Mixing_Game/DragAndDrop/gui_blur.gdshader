shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float lod: hint_range(0.0, 1.5);
uniform float dim: hint_range (0.0, 0.15);

void fragment() {
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, lod);
	COLOR = COLOR - vec4(dim, dim, dim, 0);
}
