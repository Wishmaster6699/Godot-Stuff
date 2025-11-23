# Research: S13 - Color-Shift Health/Vibe Bar
**Agent:** Claude Code Web
**Date:** 2025-11-18
**Duration:** 20 minutes
**System ID:** S13

---

## Godot 4.5 Documentation

### CanvasItem Shaders
- **URL:** https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html
- **Key Insight:** canvas_item shaders are used for all 2D elements including UI elements
- **Important:** In Godot 4.5, `hint_color` has been changed to `source_color` for color uniforms
- **Usage:** Apply ShaderMaterial to Control nodes like TextureProgressBar

### ShaderMaterial Class
- **URL:** https://docs.godotengine.org/en/4.5/classes/class_shadermaterial.html
- **Key Insight:** ShaderMaterial allows passing uniforms to shaders at runtime
- **Usage:** Create ShaderMaterial, set shader, update uniforms via `set_shader_parameter()`

### TextureProgressBar
- **URL:** https://docs.godotengine.org/en/stable/classes/class_textureprogressbar.html
- **Key Insight:** Can have material applied to change visual appearance
- **Challenge:** Material affects entire CanvasItem, not just progress texture
- **Workaround:** Use shader uniform to clip/color based on progress value

---

## Existing Projects & Examples

### Highlight Shader (Godot 4.5 Compatible)
- **URL:** https://godotshaders.com/shader/highlight-shader-godot-4-5-compat/
- **Date:** November 2, 2025
- **Key Changes for 4.5:**
  - `hint_color` → `source_color`
  - Proper alpha channel handling
  - Updated uniform syntax

### Progress Bar Shader (Godot 4.x)
- **URL:** https://github.com/Cabbage0211/progress-bar-shader
- **Architecture:** Flexible progress bar with visual effects and animations
- **Features:** Multiple display modes, customizable colors, smooth transitions

### Universal Transition Shader
- **URL:** https://godotshaders.com/shader/universal-transition-shader/
- **Date:** July 2025
- **Pattern:** Uses `smoothstep()` for smooth value interpolation
- **Technique:** Blend between colors/textures using transition uniform

---

## Code Patterns

### Smooth Color Interpolation
```glsl
shader_type canvas_item;

uniform float health_percent : hint_range(0.0, 1.0) = 1.0;
uniform vec4 color_high : source_color = vec4(0.0, 0.5, 1.0, 1.0);  // Blue
uniform vec4 color_mid : source_color = vec4(1.0, 1.0, 0.0, 1.0);   // Yellow
uniform vec4 color_low : source_color = vec4(1.0, 0.0, 0.0, 1.0);   // Red

void fragment() {
    vec4 color;
    if (health_percent > 0.5) {
        // Interpolate blue → yellow (100% to 50%)
        float t = (health_percent - 0.5) * 2.0;
        color = mix(color_mid, color_high, t);
    } else {
        // Interpolate yellow → red (50% to 0%)
        float t = health_percent * 2.0;
        color = mix(color_low, color_mid, t);
    }
    COLOR = color;
}
```

### Updating Shader Uniforms in GDScript
```gdscript
# Get the material
var material: ShaderMaterial = $HealthBar.material as ShaderMaterial

# Update health percentage uniform
material.set_shader_parameter("health_percent", current_hp / max_hp)
```

### Tween for Smooth Transitions
```gdscript
# Create tween for smooth health bar animation
var tween: Tween = create_tween()
tween.tween_method(
    _update_shader_health,
    current_health_percent,
    target_health_percent,
    0.3  # 0.3 second transition
)

func _update_shader_health(value: float) -> void:
    material.set_shader_parameter("health_percent", value)
```

---

## GDScript 4.5 Best Practices

### Type Hints
- All variables must have explicit types
- Function parameters must have type hints
- Return types must be declared

### Signals
- Use typed signal parameters
- Emit signals with `.emit()` method

### Modern Syntax
- `@export` instead of `export`
- `@onready` instead of `onready`
- `await` instead of `yield`
- `CharacterBody2D` instead of `KinematicBody2D`

---

## Key Decisions

### 1. Shader Approach
**Decision:** Use canvas_item shader with health_percent uniform
**Why:** Simple, performant, works with TextureProgressBar
**Alternative Considered:** Vertex shader (more complex, not needed)

### 2. Color Transition Logic
**Decision:** Two-stage interpolation (blue→yellow, yellow→red)
**Why:** Matches prompt requirements (100%→50%→10%)
**Implementation:** If-else with `mix()` function

### 3. Integration with Combat (S04)
**Decision:** Connect to Combatant's `health_changed` signal
**Why:** Reactive system, no polling needed
**Pattern:** `combatant.health_changed.connect(_on_health_changed)`

### 4. Particle Effects
**Decision:** Trigger GPUParticles2D on threshold crossings
**Why:** Visual feedback for critical health states
**Thresholds:** 50% (yellow sparks), 10% (red warning), 0% (defeat explosion)

### 5. Pulse Animation
**Decision:** Use AnimationPlayer for pulse effect below 20% HP
**Why:** Consistent with Godot best practices, easy to configure
**Trigger:** Check health < 20% in update method

---

## Gotchas for Tier 2

### Shader Material Setup
- **Issue:** ShaderMaterial must be created in Godot editor, not via code
- **Solution:** MCP agent creates ShaderMaterial, loads shader file, sets on node

### Particle One-Shot Triggers
- **Issue:** Particles need to trigger only once per threshold crossing
- **Solution:** Track previous health state, compare to detect crossings

### Downbeat Defeat Animation
- **Issue:** Must wait for Conductor.downbeat signal before defeat explosion
- **Solution:** Use `await Conductor.downbeat` in defeat handler

### Health Percentage Precision
- **Issue:** Float division can cause visual glitches near thresholds
- **Solution:** Use `clamp(value, 0.0, 1.0)` and proper comparison operators

---

## Godot 4.5 Specifics

### shader_type canvas_item
- Used for all 2D rendering including UI
- Runs on GPU, very performant
- Fragment shader processes each pixel

### hint_range for Uniforms
- `uniform float value : hint_range(0.0, 1.0)` creates slider in inspector
- Makes testing easier in Godot editor

### source_color (NEW in Godot 4.x)
- Replaces `hint_color` from Godot 3.x
- Enables color picker in inspector
- Example: `uniform vec4 color : source_color`

### GPUParticles2D
- Hardware-accelerated particle system
- `one_shot = true` for single burst effects
- `explosiveness = 1.0` for all particles at once

---

## Reusable Patterns

### Health Bar Color Shift Pattern
This pattern can be reused for:
- Enemy health bars
- Shield/energy bars
- Status effect indicators
- Resource meters (mana, stamina)

### Threshold Trigger Pattern
```gdscript
# Track previous state
var previous_health: int = 100

# Detect threshold crossings
func update_health(new_health: int) -> void:
    # Check 50% threshold
    if previous_health > max_hp * 0.5 and new_health <= max_hp * 0.5:
        trigger_yellow_particles()

    # Check 10% threshold
    if previous_health > max_hp * 0.1 and new_health <= max_hp * 0.1:
        trigger_red_particles()

    previous_health = new_health
```

### Beat-Synced Animation Pattern
```gdscript
# Wait for downbeat before critical animation
func play_defeat_animation() -> void:
    if conductor:
        await conductor.downbeat

    # Play explosion particles
    $DefeatExplosion.restart()
```

---

## Performance Considerations

### Shader Performance
- Color interpolation is extremely cheap on GPU
- No texture lookups needed (just math)
- Expected: <0.01ms per frame overhead

### Particle Effects
- Use GPUParticles2D (hardware accelerated)
- Keep particle count reasonable (20-50 per effect)
- One-shot particles auto-disable after completion

### Tween Optimization
- Limit one tween per health bar at a time
- Use `kill()` on old tween before creating new one

---

## Integration Points

### S04 Combat System
- **Connection:** `Combatant.health_changed` signal
- **Data Flow:** Combatant → Vibe Bar (health updates)
- **Usage:** `combatant.health_changed.connect(_on_health_changed)`

### S01 Conductor System
- **Connection:** `Conductor.downbeat` signal
- **Data Flow:** Conductor → Vibe Bar (defeat timing)
- **Usage:** `await Conductor.downbeat` before defeat animation

---

## References

### Official Documentation
- Godot 4.5 CanvasItem Shaders: https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html
- ShaderMaterial API: https://docs.godotengine.org/en/4.5/classes/class_shadermaterial.html
- TextureProgressBar API: https://docs.godotengine.org/en/stable/classes/class_textureprogressbar.html
- GPUParticles2D API: https://docs.godotengine.org/en/stable/classes/class_gpuparticles2d.html

### Community Resources
- GodotShaders.com: https://godotshaders.com/shader-type/canvas_item/
- Progress Bar Shader (GitHub): https://github.com/Cabbage0211/progress-bar-shader

### Tutorials
- Introduction to Shaders in Godot 4 (Kodeco): https://www.kodeco.com/43354079-introduction-to-shaders-in-godot-4

---

## Next Steps for Implementation

1. ✅ Research complete
2. Create `color_shift_health.gdshader` with smooth color transitions
3. Create `vibe_bar.gd` with shader parameter updates and particle triggers
4. Create `vibe_bar_config.json` with thresholds and effect settings
5. Create `HANDOFF-S13-VIBEBAR.md` with MCP agent scene setup instructions
6. Validate GDScript 4.5 syntax (no deprecated patterns)
7. Commit and push to execution branch

---

**Research Status:** ✅ COMPLETE
**Confidence Level:** HIGH - Clear implementation path identified
**Estimated Implementation Time:** 3-4 hours (Tier 1 code creation)
