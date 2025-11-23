<objective>
Implement Grind Rail Traversal (S16) - rail following with rhythm-based balance mechanic, beat-synced inputs for maintaining balance, Discord penalty for missed beats, and jump precision on upbeat.

DEPENDS ON: S01 (Conductor for beat timing), S03 (Player Controller)
CAN RUN IN PARALLEL WITH: S09, S11, S13, S14, S15, S18
</objective>

<context>
Grind Rails are traversal mechanics inspired by Jet Set Radio. Player follows a rail path while maintaining balance by pressing Left/Right on beat. Missing beats causes Discord penalty (temporary stat loss).

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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S16")`
- [ ] Quality gates: `check_quality_gates("S16")`
- [ ] Checkpoint validation: `validate_checkpoint("S16")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S16", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

## Web Research
- "Godot Path2D following"
- "Godot rhythm-based gameplay"
- "Balance mechanic game design"

## Implementation

### 1. Grind Rail System
Create `res://traversal/grind_rail.gd`:
- Rail: Path2D with curve points
- Player follows path at constant speed
- Balance bar oscillates left/right

### 2. Balance Mechanic
- Balance bar: -100 (left) to +100 (right)
- Oscillates with Conductor tempo
- Press Left on beat: Pull balance left
- Press Right on beat: Pull balance right
- Stay in green zone (-30 to +30): Safe
- Fall out of zone: Fail, fall off rail

### 3. Discord Penalty
If player misses beat or falls off:
- "Discord" status effect: -20% all stats for 5 seconds
- Visual: Red screen edge pulse
- Audio: Dissonant sound

### 4. Jump Precision
- Jump off rail: Only on upbeat (from S01 Conductor)
- Miss upbeat: Small jump (may not reach platform)
- Hit upbeat: Perfect jump (reaches intended platform)

### 5. Grind Rail Configuration
Create `res://data/grind_rail_config.json`:
```json
{
  "grind_rail_config": {
    "rail_speed": 200,
    "balance_oscillation_speed": 1.0,
    "balance_safe_zone": 30,
    "discord_penalty": {
      "stat_reduction": 0.2,
      "duration_s": 5.0
    },
    "jump_timing": {
      "perfect_upbeat_window_ms": 50,
      "jump_force_perfect": 500,
      "jump_force_miss": 250
    }
  }
}
```

### 6. Visual Feedback
- Balance bar UI (oscillating needle)
- Green safe zone indicator
- Beat markers on bar
- Discord visual effect

### 7. Test Scene
Create `res://tests/test_grind_rail.tscn`:
- Grind rail path with curves
- Platforms to jump to
- Balance bar UI display
- Beat timing visualization

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://traversal/grind_rail.gd` - Rail following system with balance mechanics
   - Complete implementations with full logic
   - Type hints, documentation, error handling
   - Integration with Conductor (S01) and Player (S03)

2. **Create all JSON data files** using the Write tool
   - `res://data/grind_rail_config.json` - Rail parameters, balance settings, jump timing
   - Valid JSON format with all required fields

3. **Create HANDOFF-S16.md** documenting:
   - Scene structures needed (rail paths, test environment)
   - MCP agent tasks (use GDAI tools)
   - Node hierarchies and property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- `res://traversal/grind_rail.gd` - Complete grind rail implementation
- `res://data/grind_rail_config.json` - Configuration data
- `HANDOFF-S16.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S16.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create rail scenes, test_grind_rail.tscn
   - `add_node` - Build node hierarchies (Path2D, PathFollow2D, UI elements)
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set rail curves, balance parameters
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S16.md` with this structure:

```markdown
# HANDOFF: S16 - Grind Rail Traversal

## Files Created by Claude Code Web

### GDScript Files
- `res://traversal/grind_rail.gd` - Rail following with rhythm-based balance

### Data Files
- `res://data/grind_rail_config.json` - Rail configuration (speed, balance, jumps)

## MCP Agent Tasks

### 1. Create Grind Rail Scene

```bash
# Create grind rail scene
create_scene res://traversal/grind_rail.tscn
add_node res://traversal/grind_rail.tscn Path2D GrindRail root
add_node res://traversal/grind_rail.tscn PathFollow2D RailFollow GrindRail
add_node res://traversal/grind_rail.tscn Sprite2D PlayerSprite RailFollow
add_node res://traversal/grind_rail.tscn CollisionShape2D Collision RailFollow
attach_script res://traversal/grind_rail.tscn GrindRail res://traversal/grind_rail.gd

# Create balance UI
add_node res://traversal/grind_rail.tscn CanvasLayer BalanceUI GrindRail
add_node res://traversal/grind_rail.tscn ProgressBar BalanceBar BalanceUI
add_node res://traversal/grind_rail.tscn Control SafeZone BalanceUI
add_node res://traversal/grind_rail.tscn Label BeatMarker BalanceUI
```

### 2. Configure Rail Properties

```bash
# Set rail curve (example path)
update_property res://traversal/grind_rail.tscn GrindRail curve "Curve2D with points at (0,0), (200,100), (400,0)"

# Set rail speed
update_property res://traversal/grind_rail.tscn GrindRail rail_speed 200

# Balance bar configuration
update_property res://traversal/grind_rail.tscn BalanceBar min_value -100
update_property res://traversal/grind_rail.tscn BalanceBar max_value 100
update_property res://traversal/grind_rail.tscn BalanceBar value 0
update_property res://traversal/grind_rail.tscn BalanceBar show_percentage false

# Safe zone indicator
update_property res://traversal/grind_rail.tscn SafeZone modulate "Color(0, 1, 0, 0.3)"
```

### 3. Create Test Scene

```bash
create_scene res://tests/test_grind_rail.tscn
add_node res://tests/test_grind_rail.tscn Node2D TestGrindRail root
add_node res://tests/test_grind_rail.tscn TileMap Platforms TestGrindRail
add_node res://tests/test_grind_rail.tscn GrindRail Rail1 TestGrindRail res://traversal/grind_rail.tscn
add_node res://tests/test_grind_rail.tscn GrindRail Rail2 TestGrindRail res://traversal/grind_rail.tscn

# Position test rails
update_property res://tests/test_grind_rail.tscn Rail1 position "Vector2(100, 200)"
update_property res://tests/test_grind_rail.tscn Rail2 position "Vector2(100, 400)"
```

## Testing Checklist

Use Godot MCP tools to test:

```bash
# Run test scene
play_scene res://tests/test_grind_rail.tscn

# Check for errors
get_godot_errors
```

### Verify:
- [ ] Player follows Path2D rail smoothly
- [ ] Balance bar oscillates with Conductor tempo (S01 integration)
- [ ] Left/Right input on beat affects balance correctly
- [ ] Falling out of safe zone (-30 to +30) causes fall
- [ ] Discord penalty applies: -20% stats for 5s
- [ ] Visual feedback: Red screen pulse on Discord
- [ ] Jump only works on Conductor upbeat
- [ ] Perfect upbeat jump (50ms window): 500 force
- [ ] Missed upbeat jump: 250 force (weak)
- [ ] Balance bar UI displays correctly
- [ ] Beat markers show on UI

### Integration Points:
- **S01 (Conductor)**: Beat timing, upbeat detection
- **S03 (Player Controller)**: Movement override during grinding
- **Grind Rail Config**: JSON data loaded correctly

## Completion

When testing passes:
1. Update `COORDINATION-DASHBOARD.md`:
   - Mark S16 as "complete"
   - Release any resource locks
   - Unblock dependent systems
2. Run framework quality gates:
   - `IntegrationTestSuite.run_all_tests()`
   - `PerformanceProfiler.profile_system("S16")`
   - `check_quality_gates("S16")`
   - `validate_checkpoint("S16")`
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S16.md, verify:

### Code Quality
- [ ] grind_rail.gd created with complete implementation (no TODOs or placeholders)
- [ ] grind_rail_config.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling for balance mechanics and jumps

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (traversal/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S16.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used

### System-Specific Verification (File Creation)
- [ ] Grind rail with Path2D following logic
- [ ] Balance bar oscillation tied to Conductor tempo
- [ ] Left/Right input detection on beat
- [ ] Discord penalty implementation (-20% stats, 5s duration)
- [ ] Jump precision logic (upbeat detection, force variation)
- [ ] Configuration data complete in JSON
- [ ] Integration with Conductor (S01) and Player (S03) documented

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
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S16")`
- [ ] Quality gates passed: `check_quality_gates("S16")`
- [ ] Checkpoint validated: `validate_checkpoint("S16")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Player follows Path2D rail smoothly at 200 speed
- [ ] Balance bar oscillates with Conductor tempo (S01)
- [ ] Left/Right input on beat affects balance correctly
- [ ] Falling out of safe zone (-30 to +30) causes fall
- [ ] Discord penalty applies: -20% stats for 5 seconds
- [ ] Visual feedback: Red screen pulse on Discord
- [ ] Jump only works on Conductor upbeat
- [ ] Perfect upbeat jump (50ms window): 500 force, reaches platform
- [ ] Missed upbeat jump: 250 force, weak jump
- [ ] Visual balance bar UI displays correctly
- [ ] Beat markers show on UI
- [ ] Integration with Conductor (S01) works
- [ ] Integration with Player (S03) works

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ grind_rail.gd complete with Path2D following and balance mechanics
- ✅ Balance oscillation logic tied to Conductor tempo
- ✅ Discord penalty implementation complete
- ✅ Jump precision logic with upbeat detection
- ✅ grind_rail_config.json complete with all parameters
- ✅ HANDOFF-S16.md provides clear MCP agent instructions
- ✅ Integration patterns documented for S01, S03
- ✅ Balance safe zone and failure logic implemented

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Grind rail scenes configured correctly in Godot editor
- ✅ Path2D following works smoothly
- ✅ Balance bar oscillates with Conductor tempo
- ✅ Beat-synced input affects balance correctly
- ✅ Discord penalty triggers and applies correctly
- ✅ Jump timing works (upbeat detection)
- ✅ Perfect vs missed jump force difference clear
- ✅ Balance UI displays and updates correctly
- ✅ All verification criteria pass
- ✅ Jet Set Radio-style grinding feel achieved

</success_criteria>

<memory_checkpoint_format>
```
System S16 (Grind Rail Traversal) Complete

FILES:
- res://traversal/grind_rail.gd
- res://data/grind_rail_config.json
- res://tests/test_grind_rail.tscn

GRIND RAIL MECHANICS:
- Path2D following at 200 speed
- Balance bar oscillates with tempo
- Left/Right on beat maintains balance
- Safe zone: -30 to +30

DISCORD PENALTY:
- Triggered by falling or missing beats
- -20% all stats for 5 seconds
- Red screen pulse, dissonant sound

JUMP PRECISION:
- Only on upbeat (Conductor integration)
- Perfect: 500 jump force
- Miss: 250 jump force

STATUS: Rhythm traversal complete
```
</memory_checkpoint_format>
