// NOTE: Shader automatically converted from Godot Engine 4.1.stable's CanvasItemMaterial.

shader_type canvas_item;
render_mode blend_mix,unshaded;

// material.set_shader_parameter("some_value", some_value)
// material.set_shader_parameter("colors", [Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1)])
uniform uvec3 brush_color = uvec3(0, 0, 0);
uniform float brush_flow = 0.0;

//uniform sampler2D canvas; // Read into this.

void stroke_to_canvas(in vec2 start, in vec2 end, in vec3 color, in float flow, in float size, in float falloff) {
	//TEXTURE
}

void vertex() {
	// Disable the built-in model to world transform (world to screen and projection will still happen later) and do it manually:
    //VERTEX = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
}