<objective>
Implement Dodging & Blocking Mechanics (S09) - advanced defensive system with i-frames, rhythm timing bonuses, stamina costs, and equipment integration. Refines placeholder dodge/block from S04 into full combat mechanics.

DEPENDS ON: S01 (Conductor), S04 (Combat), S08 (Equipment)
CAN RUN IN PARALLEL WITH: S11, S13, S14, S15, S16, S18 (Wave 1 of Job 3)
</objective>

<context>
This system elevates combat from basic attacks to skilled defensive play. It integrates:
- **S01 Conductor**: Rhythm timing for dodge/block quality
- **S04 Combat**: Core combat mechanics
- **S08 Equipment**: Equipment affects dodge speed and block effectiveness

Dodging and blocking are skill-based mechanics that reward rhythm timing mastery.

Reference:
@rhythm-rpg-implementation-guide.md
@combat-specification.md (from prompt 002)
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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S09")`
- [ ] Quality gates: `check_quality_gates("S09")`
- [ ] Checkpoint validation: `validate_checkpoint("S09")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S09", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<file_isolation>

## 🚨 FILE ISOLATION RULES - PREVENT MERGE CONFLICTS

**System ID:** S09 | **System Name:** Dodge/Block

**✅ YOU MAY MODIFY:**
```
src/systems/s09-dodgeblock/
scenes/s09-dodgeblock/
checkpoints/s09-dodgeblock-checkpoint.md
research/s09-dodgeblock-research.md
HANDOFF-S09-DODGEBLOCK.md
```

**❌ YOU MUST NOT MODIFY:** Other systems' directories, `src/core/`, `project.godot`

**See `GIT-WORKFLOW.md` for complete file isolation rules.**

</file_isolation>

<requirements>

## Web Research First
- "Godot 4.5 invincibility frames implementation"
- "Godot 4.5 cooldown system"
- "Action game dodge mechanics design"

## Implementation Tasks

### 1. Dodge System
Create `res://combat/dodge_system.gd`:

**Dodge Mechanics:**
- Button: B (from S02 InputManager)
- Cooldown: 0.5s (configurable)
- I-frames duration: Perfect = 0.3s, Good = 0.2s, Miss = 0.1s
- Rhythm timing:
  - Perfect (on beat ±50ms): Full i-frames, dodge animation plays
  - Good (on beat ±100ms): Reduced i-frames
  - Miss (>100ms): Minimal i-frames
- Visual feedback: Ghost trail effect during i-frames
- Audio: Whoosh sound, pitch varies by timing quality

### 2. Block System
Create `res://combat/block_system.gd`:

**Block Mechanics:**
- Button: X (from S02 InputManager)
- Cooldown: 1.0s (configurable)
- Stamina cost: 10 stamina (configurable)
- Damage reduction:
  - Perfect (on beat ±50ms): 85% reduction
  - Good (on beat ±100ms): 60% reduction
  - Miss (>100ms): 30% reduction
- Shield clash effect on perfect block
- Block break: If stamina = 0, block fails

### 3. Stamina System
Add to Player (S03):
```gdscript
var stamina = {
  "current": 100,
  "max": 100,
  "regen_rate": 10,  # per second
  "regen_delay": 2.0  # seconds after block
}
```

### 4. I-Frames Implementation
- Set `invulnerable = true` during dodge i-frames
- Visual feedback: Sprite modulate alpha oscillates
- Enemies' attacks pass through player (no damage)
- I-frames end: Resume vulnerability

### 5. Equipment Integration (S08)
Equipment affects dodge/block:
```json
{
  "light_boots": {
    "dodge_cooldown_modifier": -0.1,  // 10% faster cooldown
    "dodge_distance": 1.2  // 20% further dodge
  },
  "heavy_shield": {
    "block_damage_reduction": 0.1,  // +10% reduction
    "stamina_cost_modifier": 1.5  // 50% more stamina cost
  }
}
```

### 6. Configuration File
Create `res://data/dodge_block_config.json`:
```json
{
  "dodge_block_config": {
    "dodge": {
      "cooldown_s": 0.5,
      "iframe_duration_perfect": 0.3,
      "iframe_duration_good": 0.2,
      "iframe_duration_miss": 0.1,
      "dodge_distance": 64,
      "dodge_speed": 400
    },
    "block": {
      "cooldown_s": 1.0,
      "stamina_cost": 10,
      "damage_reduction_perfect": 0.85,
      "damage_reduction_good": 0.60,
      "damage_reduction_miss": 0.30,
      "block_stun_duration": 0.2
    },
    "stamina": {
      "max_stamina": 100,
      "regen_rate": 10,
      "regen_delay_after_block": 2.0
    },
    "timing_windows": {
      "perfect": 50,
      "good": 100
    }
  }
}
```

### 7. Visual Feedback
- Dodge: Ghost trail particles, sprite flash
- Block: Shield clash particles, screen shake
- Perfect timing: Screen flash, special sound effect
- Stamina bar UI (depletes on block, regens over time)

### 8. Test Scene
Create `res://tests/test_dodge_block.tscn`:
- Player vs enemy with telegraphed attacks
- Visual timing indicator (shows beat timing)
- Stamina bar display
- Dodge/block success counter (Perfect/Good/Miss)

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://combat/dodge_system.gd` - Dodge mechanics with rhythm timing, i-frames, cooldown
   - `res://combat/block_system.gd` - Block mechanics with stamina, damage reduction
   - Complete implementations with full logic
   - Type hints, documentation, error handling
   - Integration with Conductor (S01), Combat (S04), Equipment (S08)

2. **Create all JSON data files** using the Write tool
   - `res://data/dodge_block_config.json` - All dodge/block parameters, timing windows
   - Valid JSON format with all required fields

3. **Create HANDOFF-S09.md** documenting:
   - Scene structures needed (test scene for dodge/block testing)
   - MCP agent tasks (use GDAI tools)
   - Node hierarchies and property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- `res://combat/dodge_system.gd` - Complete dodge implementation
- `res://combat/block_system.gd` - Complete block implementation
- `res://data/dodge_block_config.json` - Configuration data
- `HANDOFF-S09.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S09.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create test_dodge_block.tscn
   - `add_node` - Build node hierarchies (player, enemies, UI feedback)
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set timing parameters, visual effects
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S09.md` with this structure:

```markdown
# HANDOFF: S09 - Dodge & Block Mechanics

## Files Created by Claude Code Web

### GDScript Files
- `res://combat/dodge_system.gd` - Dodge mechanics with rhythm timing, i-frames, cooldown
- `res://combat/block_system.gd` - Block mechanics with stamina, damage reduction

### Data Files
- `res://data/dodge_block_config.json` - All dodge/block parameters, timing windows

## MCP Agent Tasks

### 1. Create Test Scene

```bash
# Create dodge/block test scene
create_scene res://tests/test_dodge_block.tscn
add_node res://tests/test_dodge_block.tscn Node2D TestDodgeBlock root
add_node res://tests/test_dodge_block.tscn CharacterBody2D Player TestDodgeBlock
add_node res://tests/test_dodge_block.tscn Sprite2D PlayerSprite Player
add_node res://tests/test_dodge_block.tscn CollisionShape2D PlayerCollision Player
add_node res://tests/test_dodge_block.tscn Area2D Hurtbox Player
add_node res://tests/test_dodge_block.tscn CollisionShape2D HurtboxCollision Hurtbox

# Add test enemy with telegraphed attacks
add_node res://tests/test_dodge_block.tscn CharacterBody2D Enemy TestDodgeBlock
add_node res://tests/test_dodge_block.tscn Sprite2D EnemySprite Enemy
add_node res://tests/test_dodge_block.tscn CollisionShape2D EnemyCollision Enemy
add_node res://tests/test_dodge_block.tscn Area2D AttackArea Enemy
add_node res://tests/test_dodge_block.tscn CollisionShape2D AttackCollision AttackArea

# Add UI for feedback
add_node res://tests/test_dodge_block.tscn CanvasLayer UI TestDodgeBlock
add_node res://tests/test_dodge_block.tscn VBoxContainer UILayout UI

# Timing indicator
add_node res://tests/test_dodge_block.tscn Label BeatIndicator UILayout
add_node res://tests/test_dodge_block.tscn ProgressBar BeatProgress UILayout

# Stamina bar
add_node res://tests/test_dodge_block.tscn Label StaminaLabel UILayout
add_node res://tests/test_dodge_block.tscn ProgressBar StaminaBar UILayout

# Success counters
add_node res://tests/test_dodge_block.tscn Label DodgeCounters UILayout
add_node res://tests/test_dodge_block.tscn Label BlockCounters UILayout

# I-frame indicator
add_node res://tests/test_dodge_block.tscn Label IFrameStatus UILayout

# Instructions
add_node res://tests/test_dodge_block.tscn Label Instructions UILayout
```

### 2. Configure Test Scene Properties

```bash
# Player setup
update_property res://tests/test_dodge_block.tscn Player position "Vector2(200, 300)"
update_property res://tests/test_dodge_block.tscn PlayerCollision shape "CircleShape2D(radius=16)"
update_property res://tests/test_dodge_block.tscn HurtboxCollision shape "CircleShape2D(radius=20)"

# Enemy setup
update_property res://tests/test_dodge_block.tscn Enemy position "Vector2(600, 300)"
update_property res://tests/test_dodge_block.tscn EnemyCollision shape "CircleShape2D(radius=16)"
update_property res://tests/test_dodge_block.tscn AttackCollision shape "CircleShape2D(radius=40)"

# UI configuration
update_property res://tests/test_dodge_block.tscn UILayout position "Vector2(10, 10)"
update_property res://tests/test_dodge_block.tscn BeatIndicator text "Beat Timing: --"
update_property res://tests/test_dodge_block.tscn BeatProgress min_value 0
update_property res://tests/test_dodge_block.tscn BeatProgress max_value 100
update_property res://tests/test_dodge_block.tscn BeatProgress value 0

# Stamina bar
update_property res://tests/test_dodge_block.tscn StaminaLabel text "Stamina:"
update_property res://tests/test_dodge_block.tscn StaminaBar min_value 0
update_property res://tests/test_dodge_block.tscn StaminaBar max_value 100
update_property res://tests/test_dodge_block.tscn StaminaBar value 100
update_property res://tests/test_dodge_block.tscn StaminaBar custom_minimum_size "Vector2(200, 20)"

# Counter displays
update_property res://tests/test_dodge_block.tscn DodgeCounters text "Dodges - Perfect: 0 | Good: 0 | Miss: 0"
update_property res://tests/test_dodge_block.tscn BlockCounters text "Blocks - Perfect: 0 | Good: 0 | Miss: 0"

# I-frame status
update_property res://tests/test_dodge_block.tscn IFrameStatus text "I-Frames: Inactive"
update_property res://tests/test_dodge_block.tscn IFrameStatus modulate "Color(1, 1, 1, 1)"

# Instructions
update_property res://tests/test_dodge_block.tscn Instructions text "Press B to Dodge | Press X to Block\nTry timing with the beat for Perfect/Good quality"
update_property res://tests/test_dodge_block.tscn Instructions custom_minimum_size "Vector2(400, 60)"
```

### 3. Add Visual Effects

```bash
# Dodge ghost trail effect
add_node res://tests/test_dodge_block.tscn GPUParticles2D DodgeTrail Player
update_property res://tests/test_dodge_block.tscn DodgeTrail emitting false
update_property res://tests/test_dodge_block.tscn DodgeTrail amount 20
update_property res://tests/test_dodge_block.tscn DodgeTrail lifetime 0.3

# Block shield clash effect
add_node res://tests/test_dodge_block.tscn GPUParticles2D BlockClash Player
update_property res://tests/test_dodge_block.tscn BlockClash emitting false
update_property res://tests/test_dodge_block.tscn BlockClash amount 10
update_property res://tests/test_dodge_block.tscn BlockClash lifetime 0.2

# Perfect timing flash
add_node res://tests/test_dodge_block.tscn ColorRect PerfectFlash UI
update_property res://tests/test_dodge_block.tscn PerfectFlash modulate "Color(1, 1, 0, 0)"
update_property res://tests/test_dodge_block.tscn PerfectFlash anchor_preset 15
```

## Testing Checklist

Use Godot MCP tools to test:

```bash
# Run test scene
play_scene res://tests/test_dodge_block.tscn

# Check for errors
get_godot_errors
```

### Verify:
- [ ] Test scene runs without errors
- [ ] Press B to dodge - player becomes invulnerable during i-frames
- [ ] Dodge timing quality displayed (Perfect/Good/Miss)
- [ ] I-frame duration varies by timing quality (0.3s/0.2s/0.1s)
- [ ] Dodge cooldown prevents spam (0.5s)
- [ ] Visual feedback: Ghost trail during dodge
- [ ] Press X to block - reduces incoming damage
- [ ] Block timing quality displayed (Perfect/Good/Miss)
- [ ] Damage reduction varies by quality (85%/60%/30%)
- [ ] Stamina depletes on block (10 stamina)
- [ ] Stamina bar shows current/max stamina
- [ ] Stamina regenerates after 2s delay
- [ ] Block fails if stamina = 0
- [ ] Visual feedback: Shield clash on perfect block
- [ ] Beat indicator shows rhythm timing window
- [ ] Counters track Perfect/Good/Miss for both dodge and block

### Integration Points:
- **S01 (Conductor)**: Rhythm timing for dodge/block quality evaluation
- **S04 (Combat)**: Damage reduction applied to incoming attacks
- **S08 (Equipment)**: Equipment modifiers affect dodge/block effectiveness
- **Stamina System**: New resource management for blocking

## Completion

Update COORDINATION-DASHBOARD.md:
- Mark S09 as complete
- Release any locked resources
- Unblock S10 (Special Moves)
- Note: Advanced defensive mechanics now available
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S09.md, verify:

### Code Quality
- [ ] All .gd files created with complete implementations (no TODOs or placeholders)
- [ ] dodge_block_config.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented where needed
- [ ] Integration patterns documented (signals, method calls)

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (combat/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S09.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] Dodge system with perform_dodge(), i-frame logic, cooldown management
- [ ] Block system with perform_block(), stamina cost, damage reduction calculation
- [ ] Rhythm timing quality evaluation implemented (Perfect/Good/Miss)
- [ ] Stamina system with current/max/regen logic
- [ ] Equipment modifiers integrated
- [ ] All parameters configurable from dodge_block_config.json

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] All scenes created using `create_scene`
- [ ] All nodes added using `add_node` in correct hierarchy
- [ ] All scripts attached using `attach_script`
- [ ] All properties set using `update_property`

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S09")`
- [ ] Quality gates passed: `check_quality_gates("S09")`
- [ ] Checkpoint validated: `validate_checkpoint("S09")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Dodge activates on B button press
- [ ] Dodge timing quality calculated correctly (Perfect/Good/Miss)
- [ ] I-frames prevent damage during dodge
- [ ] I-frame duration varies by timing quality
- [ ] Dodge cooldown prevents spam (0.5s)
- [ ] Block activates on X button press
- [ ] Block timing quality calculated correctly
- [ ] Damage reduction varies by timing quality (85%/60%/30%)
- [ ] Stamina depletes on block (10 stamina)
- [ ] Stamina regenerates after 2s delay
- [ ] Block fails if stamina = 0
- [ ] Equipment modifiers apply to dodge/block stats
- [ ] Visual feedback shows timing quality (Perfect = special effect)
- [ ] Integrates with Conductor (S01) for rhythm timing
- [ ] Integrates with Combat (S04) for damage calculation

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ dodge_system.gd and block_system.gd complete with all mechanics
- ✅ dodge_block_config.json complete with all parameters
- ✅ HANDOFF-S09.md provides clear MCP agent instructions
- ✅ Rhythm timing integration implemented
- ✅ Stamina system implemented
- ✅ Integration patterns documented for S01, S04, S08

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Test scene configured correctly in Godot editor
- ✅ Dodge mechanics work with rhythm timing
- ✅ Block mechanics work with stamina and damage reduction
- ✅ I-frames prevent damage correctly
- ✅ Stamina regenerates after delay
- ✅ Equipment modifiers apply correctly
- ✅ All verification criteria pass
- ✅ System ready for dependent systems (S10)

</success_criteria>

<memory_checkpoint_format>
```
System S09 (Dodge/Block Mechanics) Complete

FILES CREATED:
- res://combat/dodge_system.gd
- res://combat/block_system.gd
- res://data/dodge_block_config.json
- res://tests/test_dodge_block.tscn

DODGE MECHANICS:
- Button: B, Cooldown: 0.5s
- I-frames: Perfect 0.3s, Good 0.2s, Miss 0.1s
- Rhythm timing from Conductor (S01)

BLOCK MECHANICS:
- Button: X, Cooldown: 1.0s
- Stamina cost: 10
- Damage reduction: Perfect 85%, Good 60%, Miss 30%

STAMINA SYSTEM:
- Max: 100, Regen: 10/s after 2s delay

EQUIPMENT INTEGRATION:
- Light boots: -10% dodge cooldown
- Heavy shields: +10% block reduction, +50% stamina cost

VISUAL FEEDBACK:
- Dodge ghost trail, block shield clash
- Perfect timing: Screen flash

INTEGRATION:
- Uses Conductor (S01) for timing evaluation
- Modifies Combat (S04) damage calculation
- Uses Equipment (S08) modifiers
- Ready for S10 (Special Moves) to build on

STATUS: Ready for S10
```
</memory_checkpoint_format>
