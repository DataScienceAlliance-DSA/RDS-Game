shader_type canvas_item;

uniform float strength : hint_range(-1.0, 1.0) = 0.5;
uniform int samples : hint_range(1, 64) = 16;

void fragment() {
    vec2 uv = UV;
    vec2 center = vec2(0.5, 0.5);
    
    // Vector from center to pixel, but clamp direction to horizontal (x-axis)
    vec2 dir = vec2(sign(uv.x - center.x), 0.0);
    
    // Blend color
    vec4 color = vec4(0.0);
    
    for (int i = 0; i < samples; i++) {
        float t = float(i) / float(samples - 1); // 0.0 to 1.0
        vec2 offset = dir * strength * t;
        color += texture(TEXTURE, uv + offset);
    }
    
    color /= float(samples);
    COLOR = color;
}