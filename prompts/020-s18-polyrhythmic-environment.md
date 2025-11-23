<objective>
Implement Polyrhythmic Environment System (S18) - animated environment elements on complex rhythms (4:3, 5:4 polyrhythms), lights pulsing to beat, machinery animating to polyrhythm, optional puzzle mechanics with timing platforms.

DEPENDS ON: S01 (Conductor for beat signals)
CAN RUN IN PARALLEL WITH: S09, S11, S13, S14, S15, S16
</objective>

<context>
The Polyrhythmic Environment brings the world to life with rhythm. Elements animate on complex polyrhythmic patterns, creating a visually dynamic game world that pulses with the music.

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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S18")`
- [ ] Quality gates: `check_quality_gates("S18")`
- [ ] Checkpoint validation: `validate_checkpoint("S18")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S18", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

## Web Research
- "Polyrhythm explained music theory"
- "Godot animation sync to audio"
- "Godot tween animation"

## Implementation

### 1. Polyrhythm System
Create `res://environment/polyrhythm_controller.gd`:
- Listens to Conductor beat signals
- Calculates polyrhythmic patterns (4:3, 5:4, 7:4)
- Emits custom signals for polyrhythm beats

### 2. Polyrhythm Patterns
```gdscript
# 4:3 polyrhythm: 4 beats over 3 beats
var pattern_4_3 = [0.0, 0.33, 0.66, 1.0]  # 4 beats
var pattern_3_4 = [0.0, 0.5, 1.0]  # 3 beats

# 5:4 polyrhythm: 5 beats over 4 beats
var pattern_5_4 = [0.0, 0.25, 0.5, 0.75, 1.0]  # 5 beats
var pattern_4_5 = [0.0, 0.33, 0.66, 1.0]  # 4 beats
```

### 3. Animated Environment Elements
Create `res://environment/rhythmic_element.gd`:
- **Lights**: Pulse on beat (brightness tween)
- **Machinery**: Rotate/move on polyrhythm
- **Doors**: Open/close on pattern
- **Platforms**: Rise/fall on timing

### 4. Polyrhythm Configuration
Create `res://data/polyrhythm_config.json`:
```json
{
  "polyrhythm_config": {
    "patterns": {
      "4_3": {
        "numerator": 4,
        "denominator": 3,
        "description": "4 over 3"
      },
      "5_4": {
        "numerator": 5,
        "denominator": 4,
        "description": "5 over 4"
      }
    },
    "element_types": {
      "light": {
        "pulse_duration": 0.2,
        "brightness_range": [0.5, 1.0]
      },
      "machinery": {
        "rotation_angle": 90,
        "move_distance": 32
      },
      "platform": {
        "rise_distance": 64,
        "move_duration": 0.5
      }
    }
  }
}
```

### 5. Timing Platform Puzzles
Create `res://environment/timing_platform.gd`:
- Platform rises/falls on polyrhythm beat
- Player must time jump to land on platform when raised
- Miss timing: Fall through or collision
- Integration with Puzzle System (S17)

### 6. Visual Feedback
- Light glow effects (CanvasItem modulate)
- Machinery particle effects
- Platform shadow (shows rise/fall state)

### 7. Audio Integration
- Conductor provides base beat (S01)
- Environmental sounds on polyrhythm beats
- Layered audio for complex rhythms

### 8. Test Scene
Create `res://tests/test_polyrhythm.tscn`:
- Lights pulsing on 4:3 pattern
- Machinery rotating on 5:4 pattern
- Timing platforms (puzzle test)
- Visual beat indicators

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://environment/polyrhythm_controller.gd` - Polyrhythm pattern calculator
   - `res://environment/polyrhythm_light.gd` - Light pulsing on polyrhythm
   - `res://environment/polyrhythm_machinery.gd` - Machinery animation on polyrhythm
   - `res://environment/timing_platform.gd` - Rise/fall platforms
   - Complete implementations with full logic
   - Type hints, documentation, error handling
   - Integration with Conductor (S01)

2. **Create all JSON data files** using the Write tool
   - `res://data/polyrhythm_config.json` - Polyrhythm patterns, timing data
   - Valid JSON format with all required fields

3. **Create HANDOFF-S18.md** documenting:
   - Scene structures needed (polyrhythmic environment objects, test scene)
   - MCP agent tasks (use GDAI tools)
   - Node hierarchies and property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- Polyrhythm scripts (controller + environmental objects)
- `res://data/polyrhythm_config.json` - Configuration data
- `HANDOFF-S18.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S18.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create polyrhythmic environment objects, test_polyrhythm.tscn
   - `add_node` - Build node hierarchies (lights, machinery, platforms)
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set polyrhythm patterns, animation parameters
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S18.md` with this structure:

```markdown
# HANDOFF: S18 - Polyrhythmic Environment

## Files Created by Claude Code Web

### GDScript Files
- `res://environment/polyrhythm_controller.gd` - Polyrhythm pattern calculator
- `res://environment/polyrhythm_light.gd` - Light pulsing on polyrhythm
- `res://environment/polyrhythm_machinery.gd` - Machinery animation on polyrhythm
- `res://environment/timing_platform.gd` - Rise/fall timing platforms

### Data Files
- `res://data/polyrhythm_config.json` - Polyrhythm patterns (4:3, 5:4, etc)

## MCP Agent Tasks

### 1. Create Polyrhythmic Environment Objects

```bash
# Polyrhythm light (4:3 pattern)
create_scene res://environment/polyrhythm_light.tscn
add_node res://environment/polyrhythm_light.tscn Light2D PolyLight root
add_node res://environment/polyrhythm_light.tscn Sprite2D LightSprite PolyLight
attach_script res://environment/polyrhythm_light.tscn PolyLight res://environment/polyrhythm_light.gd
update_property res://environment/polyrhythm_light.tscn PolyLight rhythm_pattern "4:3"

# Polyrhythm machinery (5:4 pattern)
create_scene res://environment/polyrhythm_machinery.tscn
add_node res://environment/polyrhythm_machinery.tscn Node2D PolyMachinery root
add_node res://environment/polyrhythm_machinery.tscn Sprite2D Gear PolyMachinery
add_node res://environment/polyrhythm_machinery.tscn AnimationPlayer Animator PolyMachinery
attach_script res://environment/polyrhythm_machinery.tscn PolyMachinery res://environment/polyrhythm_machinery.gd
update_property res://environment/polyrhythm_machinery.tscn PolyMachinery rhythm_pattern "5:4"

# Timing platform
create_scene res://environment/timing_platform.tscn
add_node res://environment/timing_platform.tscn AnimatableBody2D TimingPlatform root
add_node res://environment/timing_platform.tscn Sprite2D PlatformSprite TimingPlatform
add_node res://environment/timing_platform.tscn CollisionShape2D Collision TimingPlatform
attach_script res://environment/timing_platform.tscn TimingPlatform res://environment/timing_platform.gd
update_property res://environment/timing_platform.tscn TimingPlatform rhythm_pattern "4:3"
update_property res://environment/timing_platform.tscn TimingPlatform rise_height 100
```

### 2. Create Test Scene

```bash
create_scene res://tests/test_polyrhythm.tscn
add_node res://tests/test_polyrhythm.tscn Node2D TestPolyrhythm root
add_node res://tests/test_polyrhythm.tscn PolyLight Light1 TestPolyrhythm res://environment/polyrhythm_light.tscn
add_node res://tests/test_polyrhythm.tscn PolyLight Light2 TestPolyrhythm res://environment/polyrhythm_light.tscn
add_node res://tests/test_polyrhythm.tscn PolyMachinery Machinery1 TestPolyrhythm res://environment/polyrhythm_machinery.tscn
add_node res://tests/test_polyrhythm.tscn TimingPlatform Platform1 TestPolyrhythm res://environment/timing_platform.tscn
add_node res://tests/test_polyrhythm.tscn TimingPlatform Platform2 TestPolyrhythm res://environment/timing_platform.tscn

# Position objects
update_property res://tests/test_polyrhythm.tscn Light1 position "Vector2(100, 100)"
update_property res://tests/test_polyrhythm.tscn Light2 position "Vector2(300, 100)"
update_property res://tests/test_polyrhythm.tscn Machinery1 position "Vector2(500, 100)"
update_property res://tests/test_polyrhythm.tscn Platform1 position "Vector2(100, 300)"
update_property res://tests/test_polyrhythm.tscn Platform2 position "Vector2(300, 300)"

# Set different patterns
update_property res://tests/test_polyrhythm.tscn Light1 rhythm_pattern "4:3"
update_property res://tests/test_polyrhythm.tscn Light2 rhythm_pattern "5:4"
```

## Testing Checklist

Use Godot MCP tools to test:

```bash
# Run test scene
play_scene res://tests/test_polyrhythm.tscn

# Check for errors
get_godot_errors
```

### Verify:
- [ ] Polyrhythm controller calculates patterns correctly
- [ ] 4:3 polyrhythm: 4 beats over 3 beats working
- [ ] 5:4 polyrhythm: 5 beats over 4 beats working
- [ ] Lights pulse on beat (brightness tweens)
- [ ] Machinery animates on polyrhythm beats
- [ ] Timing platforms rise/fall on pattern
- [ ] Player can jump onto timing platforms
- [ ] Integration with Conductor (S01) beat signals

### Integration Points:
- **S01 (Conductor)**: Beat timing for polyrhythm calculations

## Completion

When testing passes:
1. Update `COORDINATION-DASHBOARD.md`:
   - Mark S18 as "complete"
   - Release any resource locks
   - Unblock dependent systems
2. Run framework quality gates:
   - `IntegrationTestSuite.run_all_tests()`
   - `PerformanceProfiler.profile_system("S18")`
   - `check_quality_gates("S18")`
   - `validate_checkpoint("S18")`
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S18.md, verify:

### Code Quality
- [ ] polyrhythm_controller.gd created with complete implementation (no TODOs or placeholders)
- [ ] polyrhythm_light.gd, polyrhythm_machinery.gd, timing_platform.gd all created
- [ ] polyrhythm_config.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling for polyrhythm calculations

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (environment/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S18.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used

### System-Specific Verification (File Creation)
- [ ] Polyrhythm controller with pattern calculation logic (4:3, 5:4, etc)
- [ ] Light pulsing implementation with brightness tweens
- [ ] Machinery animation implementation
- [ ] Timing platform rise/fall logic
- [ ] Configuration data complete in JSON
- [ ] Integration with Conductor (S01) documented

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] All scenes created using `create_scene`
- [ ] All nodes added using `add_node` in correct hierarchy
- [ ] All scripts attached using `attach_script`
- [ ] All properties configured using `update_property`

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S18")`
- [ ] Quality gates passed: `check_quality_gates("S18")`
- [ ] Checkpoint validated: `validate_checkpoint("S18")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Polyrhythm controller calculates patterns correctly (4:3, 5:4)
- [ ] 4:3 polyrhythm: 4 beats over 3 beats working
- [ ] 5:4 polyrhythm: 5 beats over 4 beats working
- [ ] Lights pulse on beat with brightness tweens
- [ ] Machinery animates on polyrhythm beats
- [ ] Timing platforms rise/fall on pattern correctly
- [ ] Player can jump onto timing platforms
- [ ] Integration with Conductor (S01) beat signals works
- [ ] Audio plays on polyrhythm beats
- [ ] Visual feedback is clear and rhythmic
- [ ] Optional puzzle integration with S17 ready

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ polyrhythm_controller.gd complete with pattern calculation
- ✅ polyrhythm_light.gd complete with brightness tween logic
- ✅ polyrhythm_machinery.gd complete with animation logic
- ✅ timing_platform.gd complete with rise/fall mechanics
- ✅ polyrhythm_config.json complete with pattern definitions
- ✅ HANDOFF-S18.md provides clear MCP agent instructions
- ✅ Integration patterns documented for S01 (Conductor)
- ✅ Multiple polyrhythm patterns implemented (4:3, 5:4, 7:4)

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ All polyrhythmic environment objects configured correctly
- ✅ Polyrhythm calculations working accurately
- ✅ Lights pulse on correct beat patterns
- ✅ Machinery animates on polyrhythm beats
- ✅ Timing platforms rise/fall on pattern
- ✅ Player can navigate timing platforms
- ✅ Integration with Conductor (S01) works
- ✅ Audio/visual sync is tight
- ✅ All verification criteria pass
- ✅ Polyrhythmic feel is musically accurate and engaging
- ✅ Job 3 complete - ready for Job 4 (S19-S26)

</success_criteria>

<memory_checkpoint_format>
```
System S18 (Polyrhythmic Environment) Complete

FILES:
- res://environment/polyrhythm_controller.gd
- res://environment/rhythmic_element.gd
- res://environment/timing_platform.gd
- res://data/polyrhythm_config.json
- res://tests/test_polyrhythm.tscn

POLYRHYTHM PATTERNS:
- 4:3 (4 over 3 beats)
- 5:4 (5 over 4 beats)
- 7:4 (7 over 4 beats)

ANIMATED ELEMENTS:
- Lights (pulse on beat)
- Machinery (rotate/move on polyrhythm)
- Doors (open/close on pattern)
- Platforms (rise/fall on timing)

TIMING PLATFORM PUZZLES:
- Player jumps to raised platforms
- Timing challenge based on polyrhythm
- Optional puzzle integration (S17)

INTEGRATION:
- Conductor (S01) provides base beat
- Polyrhythm controller calculates complex patterns
- Audio/visual sync

JOB 3 COMPLETE:
All 10 systems (S09-S18) implemented.
Ready for Job 4 (S19-S26).

STATUS: Environment rhythm complete, Job 3 done
```
</memory_checkpoint_format>
