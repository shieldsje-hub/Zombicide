shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.9, 0.0, 1.0);
uniform float glow_size : hint_range(1.0, 8.0) = 3.0;

void fragment() {
    COLOR = texture(TEXTURE, UV) * COLOR;
}

void light() {
    vec2 pixel_size = TEXTURE_PIXEL_SIZE * glow_size;

    float alpha = 0.0;

    for (float x = -glow_size; x <= glow_size; x += 1.0) {
        for (float y = -glow_size; y <= glow_size; y += 1.0) {
            vec2 offset = vec2(x, y) * TEXTURE_PIXEL_SIZE;
            alpha = max(alpha, texture(TEXTURE, UV + offset).a);
        }
    }

    if (alpha > texture(TEXTURE, UV).a) {
        LIGHT = glow_color;
    }
}