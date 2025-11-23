<objective>
Implement Color-Shift Health System (S13 - Vibe Bar) using shader-based visualization. Health bar transitions: Blue (100%) → Yellow (50%) → Red (10%) with particle effects and defeat animation on downbeat.

DEPENDS ON: S04 (Combat health system)
CAN RUN IN PARALLEL WITH: S09, S11, S14, S15, S16, S18
</objective>

<context>
The Vibe Bar replaces traditional health bars with dynamic color-shifting shader effects that reflect the player's "vibe" state. As health decreases, colors shift smoothly.

Reference:
@rhythm-rpg-implementation-guide.md
@vibe-code-philosophy.md @godot-mcp-command-reference.md
</context>

<framework_integration>

## AI Development Success Framework

**BEFORE STARTING**, read and follow:
- @AI-VIBE-CODE-SUCCESS-FRAMEWORK.md (Complete quality/coordination framework)

### Pre-Work Checklist
- [ ] Check `COORDINATION-DASHBOARD.md` for blockers, active work, and resource locks
- [ ] Search `knowledge-base/` for related issues or solutions
- [ ] Review `KNOWN-ISSUES.md` for this system's known problems
- [ ] Update `COORDINATION-DASHBOARD.md`: Claim work, lock any shared resources

### During Implementation
- [ ] Update `COORDINATION-DASHBOARD.md` at 25%, 50%, 75% progress milestones
- [ ] Document any issues discovered in `KNOWN-ISSUES.md`
- [ ] Use placeholder assets (see `ASSET-PIPELINE.md`) - don't wait for final art

### Before Marking Complete
Run all quality gates (see expanded verification section below):
- [ ] Integration tests: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S13")`
- [ ] Quality gates: `check_quality_gates("S13")`
- [ ] Checkpoint validation: `validate_checkpoint("S13")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S13", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<file_isolation>

## 🚨 FILE ISOLATION RULES - PREVENT MERGE CONFLICTS

**System ID:** S13 | **System Name:** Vibe Bar

**✅ YOU MAY MODIFY:**
```
src/systems/s13-vibebar/
scenes/s13-vibebar/
checkpoints/s13-vibebar-checkpoint.md
research/s13-vibebar-research.md
HANDOFF-S13-VIBEBAR.md
```

**❌ YOU MUST NOT MODIFY:** Other systems' directories, `src/core/`, `project.godot`

**See `GIT-WORKFLOW.md` for complete file isolation rules.**

</file_isolation>

<requirements>

## Web Research
- "Godot 4.5 shader tutorial"
- "Godot smooth color transition shader"
- "Godot particle effects"

## Implementation

### 1. Vibe Bar Shader
Create `res://shaders/vibe_bar.gdshader`:
```glsl
shader_type canvas_item;

uniform float health_percent : hint_range(0.0, 1.0) = 1.0;
uniform vec4 color_high = vec4(0.0, 0.5, 1.0, 1.0);  // Blue
uniform vec4 color_mid = vec4(1.0, 1.0, 0.0, 1.0);   // Yellow
uniform vec4 color_low = vec4(1.0, 0.0, 0.0, 1.0);   // Red

void fragment() {
  vec4 color;
  if (health_percent > 0.5) {
    // Blue to Yellow (100% to 50%)
    float t = (health_percent - 0.5) * 2.0;
    color = mix(color_mid, color_high, t);
  } else {
    // Yellow to Red (50% to 0%)
    float t = health_percent * 2.0;
    color = mix(color_low, color_mid, t);
  }
  COLOR = color;
}
```

### 2. Vibe Bar UI Component
Create `res://ui/vibe_bar.tscn`:
- TextureProgressBar with shader material
- Smooth transitions (tween health_percent)
- Pulse effect at low health (<20%)

### 3. Color Transition Thresholds
Create `res://data/vibe_bar_config.json`:
```json
{
  "vibe_bar_config": {
    "color_thresholds": {
      "high": { "percent": 1.0, "color": "#0080FF" },
      "mid": { "percent": 0.5, "color": "#FFFF00" },
      "low": { "percent": 0.1, "color": "#FF0000" }
    },
    "transition_speed": 0.5,
    "pulse_at_percent": 0.2,
    "pulse_speed": 2.0
  }
}
```

### 4. Particle Effects on Transitions
- Cross 50% threshold: Yellow spark particles
- Cross 10% threshold: Red warning particles
- Defeat (0%): Explosion particles on downbeat

### 5. Defeat Animation
Listen for Conductor.downbeat when health reaches 0:
- Screen flash
- Particle explosion
- Enemy/player sprite fades
- Defeat sound effect

### 6. Integration with Combat (S04)
Update Combatant.take_damage():
```gdscript
func take_damage(amount):
  stats.current_hp -= amount
  vibe_bar.update_health(stats.current_hp / stats.max_hp)
  if stats.current_hp <= 0:
    await Conductor.downbeat
    play_defeat_animation()
```

### 7. Test Scene
- Player vs enemy with Vibe Bars
- Damage buttons (test transitions)
- Health percentage display
- Particle effect preview

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://ui/vibe_bar.gd` - Vibe bar controller with shader parameter updates
   - Complete implementations with full logic
   - Type hints, documentation, error handling
   - Integration with Combat (S04) health system

2. **Create all shader files** using the Write tool
   - `res://shaders/color_shift_health.gdshader` - Color-shifting shader for health visualization
   - Complete shader with smooth color transitions

3. **Create all JSON data files** using the Write tool
   - `res://data/vibe_bar_config.json` - Color thresholds, particle effects config
   - Valid JSON format with all required fields

4. **Create HANDOFF-S13.md** documenting:
   - Scene structures needed (vibe bar UI, test scene)
   - MCP agent tasks (use GDAI tools)
   - Shader setup instructions
   - Testing steps for MCP agent

### Your Deliverables:
- `res://ui/vibe_bar.gd` - Complete vibe bar implementation
- `res://shaders/color_shift_health.gdshader` - Color-shift shader
- `res://data/vibe_bar_config.json` - Configuration data
- `HANDOFF-S13.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S13.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create vibe_bar.tscn, test_vibe_bar.tscn
   - `add_node` - Build node hierarchies (TextureProgressBar, particles, shaders)
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set shader materials, colors, particle effects
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S13.md` with this structure:

```markdown
# HANDOFF: S13 - Color-Shift Health/Vibe Bar

## Files Created by Claude Code Web

### GDScript Files
- `res://ui/vibe_bar.gd` - Vibe bar controller with shader parameter updates and particle effects

### Shader Files
- `res://shaders/color_shift_health.gdshader` - Color-shifting shader for health visualization (blue → yellow → red)

### Data Files
- `res://data/vibe_bar_config.json` - Color thresholds, transition speeds, particle effect config

## MCP Agent Tasks

### 1. Create Vibe Bar UI Component

```bash
# Create vibe bar scene
create_scene res://ui/vibe_bar.tscn
add_node res://ui/vibe_bar.tscn Control VibeBar root
add_node res://ui/vibe_bar.tscn Panel Background VibeBar
add_node res://ui/vibe_bar.tscn TextureProgressBar HealthBar VibeBar
add_node res://ui/vibe_bar.tscn Label HealthText VibeBar

# Add particle effects
add_node res://ui/vibe_bar.tscn GPUParticles2D YellowSparkles VibeBar
add_node res://ui/vibe_bar.tscn GPUParticles2D RedWarning VibeBar
add_node res://ui/vibe_bar.tscn GPUParticles2D DefeatExplosion VibeBar

# Add pulse animation for low health
add_node res://ui/vibe_bar.tscn AnimationPlayer PulseAnimation VibeBar

# Attach vibe bar script
attach_script res://ui/vibe_bar.tscn VibeBar res://ui/vibe_bar.gd
```

### 2. Configure Vibe Bar Properties

```bash
# Container setup
update_property res://ui/vibe_bar.tscn VibeBar custom_minimum_size "Vector2(200, 30)"
update_property res://ui/vibe_bar.tscn VibeBar anchor_preset 5

# Background panel
update_property res://ui/vibe_bar.tscn Background anchor_preset 15

# Health bar with shader material
update_property res://ui/vibe_bar.tscn HealthBar anchor_preset 15
update_property res://ui/vibe_bar.tscn HealthBar max_value 100
update_property res://ui/vibe_bar.tscn HealthBar value 100
update_property res://ui/vibe_bar.tscn HealthBar nine_patch_stretch true

# Health text
update_property res://ui/vibe_bar.tscn HealthText text "100%"
update_property res://ui/vibe_bar.tscn HealthText horizontal_alignment 1
update_property res://ui/vibe_bar.tscn HealthText vertical_alignment 1
update_property res://ui/vibe_bar.tscn HealthText anchor_preset 15

# Yellow sparkle particles (trigger at 50%)
update_property res://ui/vibe_bar.tscn YellowSparkles emitting false
update_property res://ui/vibe_bar.tscn YellowSparkles amount 20
update_property res://ui/vibe_bar.tscn YellowSparkles lifetime 0.5
update_property res://ui/vibe_bar.tscn YellowSparkles one_shot true
update_property res://ui/vibe_bar.tscn YellowSparkles explosiveness 1.0

# Red warning particles (trigger at 10%)
update_property res://ui/vibe_bar.tscn RedWarning emitting false
update_property res://ui/vibe_bar.tscn RedWarning amount 30
update_property res://ui/vibe_bar.tscn RedWarning lifetime 0.3
update_property res://ui/vibe_bar.tscn RedWarning one_shot true
update_property res://ui/vibe_bar.tscn RedWarning explosiveness 1.0

# Defeat explosion particles (trigger at 0%)
update_property res://ui/vibe_bar.tscn DefeatExplosion emitting false
update_property res://ui/vibe_bar.tscn DefeatExplosion amount 50
update_property res://ui/vibe_bar.tscn DefeatExplosion lifetime 1.0
update_property res://ui/vibe_bar.tscn DefeatExplosion one_shot true
update_property res://ui/vibe_bar.tscn DefeatExplosion explosiveness 1.0
```

### 3. Apply Shader Material to Health Bar

```bash
# Create shader material and apply to HealthBar
# Note: Shader material creation requires manual setup in Godot editor
# 1. Select HealthBar node
# 2. In Inspector, Material > New ShaderMaterial
# 3. In ShaderMaterial, Shader > Load res://shaders/color_shift_health.gdshader
# 4. Verify shader uniforms appear: health_percent, color_high, color_mid, color_low
```

### 4. Create Test Vibe Bar Scene

```bash
create_scene res://tests/test_vibe_bar.tscn
add_node res://tests/test_vibe_bar.tscn Node2D TestVibeBar root

# Add player and enemy with vibe bars
add_node res://tests/test_vibe_bar.tscn CharacterBody2D Player TestVibeBar
add_node res://tests/test_vibe_bar.tscn Sprite2D PlayerSprite Player
add_node res://tests/test_vibe_bar.tscn CollisionShape2D PlayerCollision Player
add_node res://tests/test_vibe_bar.tscn Control PlayerVibeBar Player res://ui/vibe_bar.tscn

add_node res://tests/test_vibe_bar.tscn CharacterBody2D Enemy TestVibeBar
add_node res://tests/test_vibe_bar.tscn Sprite2D EnemySprite Enemy
add_node res://tests/test_vibe_bar.tscn CollisionShape2D EnemyCollision Enemy
add_node res://tests/test_vibe_bar.tscn Control EnemyVibeBar Enemy res://ui/vibe_bar.tscn

# Add UI for testing
add_node res://tests/test_vibe_bar.tscn CanvasLayer UI TestVibeBar
add_node res://tests/test_vibe_bar.tscn Label Instructions UI
add_node res://tests/test_vibe_bar.tscn VBoxContainer DamageControls UI
add_node res://tests/test_vibe_bar.tscn Label PlayerLabel DamageControls
add_node res://tests/test_vibe_bar.tscn HBoxContainer PlayerButtons DamageControls
add_node res://tests/test_vibe_bar.tscn Button Damage10 PlayerButtons
add_node res://tests/test_vibe_bar.tscn Button Damage25 PlayerButtons
add_node res://tests/test_vibe_bar.tscn Button Damage50 PlayerButtons
add_node res://tests/test_vibe_bar.tscn Button Heal50 PlayerButtons
add_node res://tests/test_vibe_bar.tscn Button Reset PlayerButtons

add_node res://tests/test_vibe_bar.tscn Label EnemyLabel DamageControls
add_node res://tests/test_vibe_bar.tscn HBoxContainer EnemyButtons DamageControls
add_node res://tests/test_vibe_bar.tscn Button EnemyDamage10 EnemyButtons
add_node res://tests/test_vibe_bar.tscn Button EnemyDamage25 EnemyButtons
add_node res://tests/test_vibe_bar.tscn Button EnemyDamage50 EnemyButtons
add_node res://tests/test_vibe_bar.tscn Button EnemyHeal50 EnemyButtons
add_node res://tests/test_vibe_bar.tscn Button EnemyReset EnemyButtons

add_node res://tests/test_vibe_bar.tscn VBoxContainer ColorInfo UI
add_node res://tests/test_vibe_bar.tscn Label ColorGuide ColorInfo
add_node res://tests/test_vibe_bar.tscn Label BlueInfo ColorInfo
add_node res://tests/test_vibe_bar.tscn Label YellowInfo ColorInfo
add_node res://tests/test_vibe_bar.tscn Label RedInfo ColorInfo

# Configure test scene
update_property res://tests/test_vibe_bar.tscn Player position "Vector2(300, 300)"
update_property res://tests/test_vibe_bar.tscn PlayerCollision shape "CircleShape2D(radius=16)"
update_property res://tests/test_vibe_bar.tscn PlayerVibeBar position "Vector2(-100, -50)"

update_property res://tests/test_vibe_bar.tscn Enemy position "Vector2(500, 300)"
update_property res://tests/test_vibe_bar.tscn EnemyCollision shape "CircleShape2D(radius=16)"
update_property res://tests/test_vibe_bar.tscn EnemyVibeBar position "Vector2(-100, -50)"

# UI setup
update_property res://tests/test_vibe_bar.tscn Instructions text "Test Vibe Bar: Watch color transitions (Blue → Yellow → Red)"
update_property res://tests/test_vibe_bar.tscn Instructions position "Vector2(10, 10)"

update_property res://tests/test_vibe_bar.tscn DamageControls position "Vector2(10, 50)"
update_property res://tests/test_vibe_bar.tscn PlayerLabel text "Player Health:"
update_property res://tests/test_vibe_bar.tscn Damage10 text "-10 HP"
update_property res://tests/test_vibe_bar.tscn Damage25 text "-25 HP"
update_property res://tests/test_vibe_bar.tscn Damage50 text "-50 HP"
update_property res://tests/test_vibe_bar.tscn Heal50 text "+50 HP"
update_property res://tests/test_vibe_bar.tscn Reset text "Reset"

update_property res://tests/test_vibe_bar.tscn EnemyLabel text "Enemy Health:"
update_property res://tests/test_vibe_bar.tscn EnemyDamage10 text "-10 HP"
update_property res://tests/test_vibe_bar.tscn EnemyDamage25 text "-25 HP"
update_property res://tests/test_vibe_bar.tscn EnemyDamage50 text "-50 HP"
update_property res://tests/test_vibe_bar.tscn EnemyHeal50 text "+50 HP"
update_property res://tests/test_vibe_bar.tscn EnemyReset text "Reset"

update_property res://tests/test_vibe_bar.tscn ColorInfo position "Vector2(10, 250)"
update_property res://tests/test_vibe_bar.tscn ColorGuide text "Color Guide:"
update_property res://tests/test_vibe_bar.tscn BlueInfo text "  Blue: 100% - 51% HP"
update_property res://tests/test_vibe_bar.tscn YellowInfo text "  Yellow: 50% - 11% HP (sparks at 50%)"
update_property res://tests/test_vibe_bar.tscn RedInfo text "  Red: 10% - 0% HP (warning at 10%, pulse <20%)"
```

## Testing Checklist

Use Godot MCP tools to test:

```bash
# Run test scene
play_scene res://tests/test_vibe_bar.tscn

# Check for errors
get_godot_errors
```

### Verify:
- [ ] Vibe bar scene created with TextureProgressBar and shader material
- [ ] Shader material applied with color_shift_health.gdshader
- [ ] Health bar displays at 100% (blue color) initially
- [ ] Damaging to 75% HP: Color shifts from blue toward yellow
- [ ] Damaging to 50% HP: Color is yellow, yellow sparkle particles trigger
- [ ] Damaging to 30% HP: Color shifts from yellow toward red
- [ ] Damaging to 20% HP: Pulse animation activates (pulsing effect)
- [ ] Damaging to 10% HP: Color is red, red warning particles trigger
- [ ] Damaging to 0% HP: Defeat explosion particles trigger on downbeat
- [ ] Defeat animation waits for Conductor.downbeat signal (S01 integration)
- [ ] Color transitions are smooth (tween interpolation, 0.5s transition speed)
- [ ] Healing updates color correctly (red → yellow → blue)
- [ ] Health percentage text updates correctly
- [ ] Particle effects trigger only once per threshold crossing
- [ ] Pulse effect only active when health <20%
- [ ] No shader compilation errors
- [ ] Performance is good (60fps)
- [ ] Integration with Combat (S04) health system works
- [ ] Vibe bar updates when Combatant.take_damage() called

### Integration Points:
- **S04 (Combat)**: Vibe bar updates from Combatant health changes
- **S01 (Conductor)**: Defeat animation syncs with downbeat signal

## Completion

Update COORDINATION-DASHBOARD.md:
- Mark S13 as complete
- Release any resource locks
- Note visual polish complete for health feedback
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S13.md, verify:

### Code Quality
- [ ] vibe_bar.gd created with complete implementation (no TODOs or placeholders)
- [ ] color_shift_health.gdshader created with complete shader code
- [ ] vibe_bar_config.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Shader parameters well-documented

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (ui/, shaders/, data/)
- [ ] Code follows GDScript style guide
- [ ] Shader follows GLSL best practices
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S13.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used

### System-Specific Verification (File Creation)
- [ ] Vibe bar controller with update_health() and set_vibe_state() methods
- [ ] Shader with smooth color interpolation logic
- [ ] Health percentage mapping to shader uniform
- [ ] Color threshold definitions in config JSON
- [ ] Particle effect configuration in config JSON
- [ ] Integration with Combat (S04) health system documented

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] All scenes created using `create_scene`
- [ ] All nodes added using `add_node` in correct hierarchy
- [ ] Shader material applied using `update_property`
- [ ] All scripts attached using `attach_script`

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S13")`
- [ ] Quality gates passed: `check_quality_gates("S13")`
- [ ] Checkpoint validated: `validate_checkpoint("S13")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Vibe Bar shader compiles without errors
- [ ] Color transitions smoothly from blue → yellow → red
- [ ] Health updates reflected in shader health_percent uniform
- [ ] Particle effects trigger at 50% and 10% thresholds
- [ ] Pulse effect activates below 20% health
- [ ] Defeat animation waits for downbeat (S01 integration)
- [ ] Defeat particle explosion plays
- [ ] Integration with Combat (S04) health system works
- [ ] Shader performance is acceptable (60fps)
- [ ] Visual feedback is clear and impactful

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ vibe_bar.gd complete with health update logic
- ✅ color_shift_health.gdshader complete with smooth color transitions
- ✅ vibe_bar_config.json complete with all thresholds and effects
- ✅ HANDOFF-S13.md provides clear MCP agent instructions
- ✅ Shader logic optimized for performance
- ✅ Integration patterns documented for S01, S04

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Vibe bar UI configured correctly in Godot editor
- ✅ Shader compiles and runs at 60fps
- ✅ Color transitions work smoothly
- ✅ Particle effects trigger at correct thresholds
- ✅ Downbeat death animation works
- ✅ Integration with Combat health system works
- ✅ All verification criteria pass
- ✅ Visual polish complete for health feedback

</success_criteria>

<memory_checkpoint_format>
```
System S13 (Color-Shift Health / Vibe Bar) Complete

FILES:
- res://shaders/vibe_bar.gdshader
- res://ui/vibe_bar.tscn
- res://data/vibe_bar_config.json
- res://tests/test_vibe_bar.tscn

SHADER EFFECTS:
- Color transition: Blue (100%) → Yellow (50%) → Red (10%)
- Smooth interpolation between colors
- Pulse effect at <20% HP

PARTICLE EFFECTS:
- Yellow sparks at 50% threshold
- Red warning at 10% threshold
- Explosion on defeat (downbeat synced)

DEFEAT ANIMATION:
- Waits for Conductor downbeat (S01)
- Screen flash + particle explosion
- Enemy/player fade out

INTEGRATION:
- Replaces placeholder health bars from S04
- Uses Conductor (S01) for defeat timing

STATUS: Visual polish complete
```
</memory_checkpoint_format>
