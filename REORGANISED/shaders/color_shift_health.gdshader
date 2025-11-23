// Godot 4.5 | GLSL Shader
// System: S13 - Color-Shift Health/Vibe Bar
// Created: 2025-11-18
// Dependencies: None (standalone shader)
//
// Color-shifting health bar shader that transitions between three colors
// based on current health percentage:
// - Blue (100% - 51%): Healthy state
// - Yellow (50% - 11%): Warning state
// - Red (10% - 0%): Critical state
//
// Uses smooth color interpolation for seamless transitions

shader_type canvas_item;

// ═════════════════════════════════════════════════════════════════════════════
// Uniforms (adjustable parameters)
// ═════════════════════════════════════════════════════════════════════════════

/// Current health as percentage (0.0 = 0% HP, 1.0 = 100% HP)
uniform float health_percent : hint_range(0.0, 1.0) = 1.0;

/// High health color (100% - 51% HP) - Default: Blue
uniform vec4 color_high : source_color = vec4(0.0, 0.5, 1.0, 1.0);

/// Mid health color (50% - 11% HP) - Default: Yellow
uniform vec4 color_mid : source_color = vec4(1.0, 1.0, 0.0, 1.0);

/// Low health color (10% - 0% HP) - Default: Red
uniform vec4 color_low : source_color = vec4(1.0, 0.0, 0.0, 1.0);

/// Brightness boost for visual impact (1.0 = normal, 1.2 = +20% brightness)
uniform float brightness : hint_range(0.5, 2.0) = 1.0;

/// Enable/disable smooth gradient vs solid color
uniform bool use_gradient : hint_range(0.0, 1.0) = true;

// ═════════════════════════════════════════════════════════════════════════════
// Fragment Shader (runs for each pixel)
// ═════════════════════════════════════════════════════════════════════════════

void fragment() {
	// Clamp health_percent to valid range [0.0, 1.0]
	float hp = clamp(health_percent, 0.0, 1.0);

	// Initialize color
	vec4 final_color;

	// Two-stage color interpolation based on health percentage
	if (hp > 0.5) {
		// Stage 1: Blue → Yellow (100% to 50%)
		// Calculate interpolation factor (0.0 at 50%, 1.0 at 100%)
		float t = (hp - 0.5) * 2.0;

		// Smoothstep for even smoother transition (optional enhancement)
		if (use_gradient) {
			t = smoothstep(0.0, 1.0, t);
		}

		// Mix between mid color (yellow) and high color (blue)
		final_color = mix(color_mid, color_high, t);

	} else {
		// Stage 2: Yellow → Red (50% to 0%)
		// Calculate interpolation factor (0.0 at 0%, 1.0 at 50%)
		float t = hp * 2.0;

		// Smoothstep for even smoother transition (optional enhancement)
		if (use_gradient) {
			t = smoothstep(0.0, 1.0, t);
		}

		// Mix between low color (red) and mid color (yellow)
		final_color = mix(color_low, color_mid, t);
	}

	// Apply brightness multiplier
	final_color.rgb *= brightness;

	// Preserve original texture's alpha if using a textured bar
	// This allows the shader to work with both solid colors and textures
	final_color.a *= COLOR.a;

	// Set final pixel color
	COLOR = final_color;
}

// ═════════════════════════════════════════════════════════════════════════════
// Usage Notes (for MCP Agent - Tier 2)
// ═════════════════════════════════════════════════════════════════════════════
//
// 1. Apply to TextureProgressBar or ColorRect via ShaderMaterial
// 2. Update health_percent uniform from GDScript:
//    material.set_shader_parameter("health_percent", current_hp / max_hp)
//
// 3. Customize colors in Godot editor:
//    - Select node with shader
//    - Inspector > Material > Shader Parameters
//    - Adjust color_high, color_mid, color_low
//
// 4. Performance: Very efficient, runs entirely on GPU
//    Expected overhead: <0.01ms per frame
//
// 5. Testing colors:
//    - health_percent = 1.0  → Blue
//    - health_percent = 0.75 → Blue-Yellow blend
//    - health_percent = 0.5  → Yellow
//    - health_percent = 0.25 → Yellow-Red blend
//    - health_percent = 0.1  → Red
//    - health_percent = 0.0  → Red (critical)
//
// ═════════════════════════════════════════════════════════════════════════════
