<objective>
Implement Special Moves System (S10) - button combo system with rhythm-gated execution (upbeat only), resource costs, weapon-specific effects, and reusable combo library. Adds depth to combat beyond basic attacks.

DEPENDS ON: S01 (Conductor upbeat), S04 (Combat), S07 (Weapons), S09 (Dodge for combo chains)
BLOCKS: None (final combat system)
</objective>

<context>
Special Moves are powerful attacks triggered by button combos, executable only on Conductor upbeats. Each weapon type has unique special moves. This system uses the input buffer from S02 to detect combos.

Reference:
@rhythm-rpg-implementation-guide.md @combat-specification.md
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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S10")`
- [ ] Quality gates: `check_quality_gates("S10")`
- [ ] Checkpoint validation: `validate_checkpoint("S10")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S10", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<file_isolation>

## 🚨 FILE ISOLATION RULES - PREVENT MERGE CONFLICTS

**System ID:** S10 | **System Name:** Special Moves

**✅ YOU MAY MODIFY:**
```
src/systems/s10-specialmoves/
scenes/s10-specialmoves/
checkpoints/s10-specialmoves-checkpoint.md
research/s10-specialmoves-research.md
HANDOFF-S10-SPECIALMOVES.md
```

**❌ YOU MUST NOT MODIFY:** Other systems' directories, `src/core/`, `project.godot`

**See `GIT-WORKFLOW.md` for complete file isolation rules.**

</file_isolation>

<requirements>

## Web Research
- "Godot button combo detection"
- "Fighting game input buffer"
- "Godot animation tree combat"

## Implementation

### 1. Combo Detection
Create `res://combat/combo_detector.gd`:
- Reads InputManager buffer (S02)
- Detects patterns: A+B, A+Down, B+Up, etc.
- 200ms window for combo completion
- Listens for Conductor.upbeat signal

### 2. Special Moves Database
Create `res://data/special_moves.json`:
```json
{
  "special_moves": [
    {
      "id": "sword_spin_slash",
      "name": "Spin Slash",
      "weapon_type": "sword",
      "button_combo": ["A", "B"],
      "resource_cost": { "stamina": 25 },
      "damage_multiplier": 2.5,
      "effects": ["knockback", "aoe_small"],
      "animation": "spin_slash",
      "cooldown_s": 3.0
    }
  ]
}
```

### 3. Resource System
Stamina (from S09) + Energy:
```gdscript
var resources = {
  "stamina": 100,
  "energy": 50  # New resource for special moves
}
```

### 4. Upbeat Gating
```gdscript
func _on_upbeat():
  if combo_detected and has_resources():
    execute_special_move()
```

### 5. Weapon-Specific Moves
- Sword: Spin Slash (A+B), Thrust (A+Down)
- Axe: Overhead Smash (A+B), Whirlwind (B+B+B)
- Staff: Fireball (A+Up), Ice Lance (B+Down)
- etc.

### 6. Test Scene
- Display combo inputs
- Show upbeat timing window
- Resource bars (stamina, energy)
- Damage numbers for special moves

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://combat/special_moves_system.gd` - Combo detection, upbeat gating, move execution
   - Complete implementations with full logic
   - Type hints, documentation, error handling
   - Integration with Conductor (S01 upbeat), Combat (S04), Weapons (S07), Dodge (S09)

2. **Create all JSON data files** using the Write tool
   - `res://data/special_moves.json` - All special move definitions with combos, effects, costs
   - Valid JSON format with all required fields

3. **Create HANDOFF-S10.md** documenting:
   - Scene structures needed (test scene for combo testing)
   - MCP agent tasks (use GDAI tools)
   - Node hierarchies and property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- `res://combat/special_moves_system.gd` - Complete special moves implementation
- `res://data/special_moves.json` - Special moves database
- `HANDOFF-S10.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S10.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create test_special_moves.tscn
   - `add_node` - Build node hierarchies (player, combat arena, combo display UI)
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set timing parameters, visual effects
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S10.md` with this structure:

```markdown
# HANDOFF: S10 - Special Moves System

## Files Created by Claude Code Web

### GDScript Files
- `res://combat/special_moves_system.gd` - Combo detection, upbeat gating, move execution

### Data Files
- `res://data/special_moves.json` - All special move definitions with combos, effects, costs

## MCP Agent Tasks

### 1. Create Test Scene

```bash
# Create special moves test scene
create_scene res://tests/test_special_moves.tscn
add_node res://tests/test_special_moves.tscn Node2D TestSpecialMoves root

# Add player
add_node res://tests/test_special_moves.tscn CharacterBody2D Player TestSpecialMoves
add_node res://tests/test_special_moves.tscn Sprite2D PlayerSprite Player
add_node res://tests/test_special_moves.tscn CollisionShape2D PlayerCollision Player

# Add test dummy enemy
add_node res://tests/test_special_moves.tscn StaticBody2D Dummy TestSpecialMoves
add_node res://tests/test_special_moves.tscn Sprite2D DummySprite Dummy
add_node res://tests/test_special_moves.tscn CollisionShape2D DummyCollision Dummy

# Add UI for feedback
add_node res://tests/test_special_moves.tscn CanvasLayer UI TestSpecialMoves
add_node res://tests/test_special_moves.tscn VBoxContainer UILayout UI

# Combo display
add_node res://tests/test_special_moves.tscn Label ComboTitle UILayout
add_node res://tests/test_special_moves.tscn Label ComboInput UILayout
add_node res://tests/test_special_moves.tscn Label ComboDetected UILayout

# Upbeat indicator
add_node res://tests/test_special_moves.tscn Label UpbeatTitle UILayout
add_node res://tests/test_special_moves.tscn Label UpbeatStatus UILayout
add_node res://tests/test_special_moves.tscn ProgressBar UpbeatTimer UILayout

# Resource bars
add_node res://tests/test_special_moves.tscn Label StaminaLabel UILayout
add_node res://tests/test_special_moves.tscn ProgressBar StaminaBar UILayout
add_node res://tests/test_special_moves.tscn Label EnergyLabel UILayout
add_node res://tests/test_special_moves.tscn ProgressBar EnergyBar UILayout

# Special move feedback
add_node res://tests/test_special_moves.tscn Label MoveExecuted UILayout
add_node res://tests/test_special_moves.tscn Label DamageDisplay UILayout

# Instructions
add_node res://tests/test_special_moves.tscn Label Instructions UILayout

# Weapon selection
add_node res://tests/test_special_moves.tscn HBoxContainer WeaponButtons UILayout
add_node res://tests/test_special_moves.tscn Button EquipSword WeaponButtons
add_node res://tests/test_special_moves.tscn Button EquipAxe WeaponButtons
add_node res://tests/test_special_moves.tscn Button EquipStaff WeaponButtons
```

### 2. Configure Test Scene Properties

```bash
# Player setup
update_property res://tests/test_special_moves.tscn Player position "Vector2(300, 300)"
update_property res://tests/test_special_moves.tscn PlayerCollision shape "CircleShape2D(radius=16)"

# Dummy enemy setup
update_property res://tests/test_special_moves.tscn Dummy position "Vector2(600, 300)"
update_property res://tests/test_special_moves.tscn DummyCollision shape "RectangleShape2D(size=Vector2(64,64))"

# UI configuration
update_property res://tests/test_special_moves.tscn UILayout position "Vector2(10, 10)"

# Combo display
update_property res://tests/test_special_moves.tscn ComboTitle text "Button Combo:"
update_property res://tests/test_special_moves.tscn ComboInput text "Input: []"
update_property res://tests/test_special_moves.tscn ComboDetected text "Detected: None"
update_property res://tests/test_special_moves.tscn ComboDetected modulate "Color(0, 1, 0, 1)"

# Upbeat indicator
update_property res://tests/test_special_moves.tscn UpbeatTitle text "Upbeat Window:"
update_property res://tests/test_special_moves.tscn UpbeatStatus text "Waiting for upbeat..."
update_property res://tests/test_special_moves.tscn UpbeatTimer min_value 0
update_property res://tests/test_special_moves.tscn UpbeatTimer max_value 100
update_property res://tests/test_special_moves.tscn UpbeatTimer value 0
update_property res://tests/test_special_moves.tscn UpbeatTimer custom_minimum_size "Vector2(200, 20)"

# Resource bars
update_property res://tests/test_special_moves.tscn StaminaLabel text "Stamina:"
update_property res://tests/test_special_moves.tscn StaminaBar min_value 0
update_property res://tests/test_special_moves.tscn StaminaBar max_value 100
update_property res://tests/test_special_moves.tscn StaminaBar value 100
update_property res://tests/test_special_moves.tscn StaminaBar custom_minimum_size "Vector2(200, 20)"

update_property res://tests/test_special_moves.tscn EnergyLabel text "Energy:"
update_property res://tests/test_special_moves.tscn EnergyBar min_value 0
update_property res://tests/test_special_moves.tscn EnergyBar max_value 50
update_property res://tests/test_special_moves.tscn EnergyBar value 50
update_property res://tests/test_special_moves.tscn EnergyBar custom_minimum_size "Vector2(200, 20)"

# Special move feedback
update_property res://tests/test_special_moves.tscn MoveExecuted text "Special Move: --"
update_property res://tests/test_special_moves.tscn MoveExecuted modulate "Color(1, 1, 0, 1)"
update_property res://tests/test_special_moves.tscn DamageDisplay text "Damage: --"

# Instructions
update_property res://tests/test_special_moves.tscn Instructions text "Try combos: A+B (Spin Slash) | A+Down (Thrust) | B+B+B (Whirlwind)\nMust execute on upbeat! Watch the upbeat timer."
update_property res://tests/test_special_moves.tscn Instructions custom_minimum_size "Vector2(500, 60)"

# Weapon selection buttons
update_property res://tests/test_special_moves.tscn EquipSword text "Equip Sword"
update_property res://tests/test_special_moves.tscn EquipAxe text "Equip Axe"
update_property res://tests/test_special_moves.tscn EquipStaff text "Equip Staff"
```

### 3. Add Visual Effects

```bash
# Special move effect particles
add_node res://tests/test_special_moves.tscn GPUParticles2D SpecialMoveEffect Player
update_property res://tests/test_special_moves.tscn SpecialMoveEffect emitting false
update_property res://tests/test_special_moves.tscn SpecialMoveEffect amount 30
update_property res://tests/test_special_moves.tscn SpecialMoveEffect lifetime 0.5

# Combo success flash
add_node res://tests/test_special_moves.tscn ColorRect ComboFlash UI
update_property res://tests/test_special_moves.tscn ComboFlash modulate "Color(1, 0.5, 0, 0)"
update_property res://tests/test_special_moves.tscn ComboFlash anchor_preset 15

# Upbeat active indicator
add_node res://tests/test_special_moves.tscn ColorRect UpbeatIndicator UI
update_property res://tests/test_special_moves.tscn UpbeatIndicator modulate "Color(0, 1, 0, 0)"
update_property res://tests/test_special_moves.tscn UpbeatIndicator anchor_preset 15
update_property res://tests/test_special_moves.tscn UpbeatIndicator size "Vector2(100, 100)"
update_property res://tests/test_special_moves.tscn UpbeatIndicator position "Vector2(10, 500)"
```

## Testing Checklist

Use Godot MCP tools to test:

```bash
# Run test scene
play_scene res://tests/test_special_moves.tscn

# Check for errors
get_godot_errors
```

### Verify:
- [ ] Test scene runs without errors
- [ ] Input buffer tracks button presses (displayed in UI)
- [ ] Combo detection works for button sequences (A+B, A+Down, B+B+B, etc.)
- [ ] Upbeat window indicator shows when upbeat is active
- [ ] Special moves ONLY execute during upbeat window
- [ ] Special moves fail to execute outside upbeat window
- [ ] Resource costs deducted when special move executes (stamina/energy)
- [ ] Special move execution blocked if insufficient resources
- [ ] Visual feedback: Particles play on special move execution
- [ ] Visual feedback: Screen flash on successful combo
- [ ] Damage multiplier applied correctly (2.5x for Spin Slash, etc.)
- [ ] Weapon-specific moves load from JSON (sword, axe, staff)
- [ ] Equipping different weapons changes available special moves
- [ ] Cooldown prevents spamming same special move (3.0s)
- [ ] Combo detection has 200ms window for completion
- [ ] Move names and effects displayed in UI

### Integration Points:
- **S01 (Conductor)**: Upbeat signal gates special move execution
- **S02 (InputManager)**: Input buffer for combo detection
- **S04 (Combat)**: Damage multiplier applied to attacks
- **S07 (Weapons)**: Weapon-specific moves loaded from database
- **S09 (Dodge)**: Combo chains can include dodge cancels

## Completion

Update COORDINATION-DASHBOARD.md:
- Mark S10 as complete
- Release any locked resources
- Note: Combat system complete (S04, S09, S10 all integrated)
- All combat mechanics now available for advanced gameplay
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S10.md, verify:

### Code Quality
- [ ] special_moves_system.gd created with complete implementation (no TODOs or placeholders)
- [ ] special_moves.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented where needed
- [ ] Integration patterns documented (signals, method calls)

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (combat/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S10.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] Combo detection logic implemented
- [ ] Upbeat timing gate logic implemented
- [ ] Special move execution logic implemented
- [ ] Resource cost system integrated
- [ ] Weapon-specific move logic implemented
- [ ] All special moves defined in special_moves.json

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
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S10")`
- [ ] Quality gates passed: `check_quality_gates("S10")`
- [ ] Checkpoint validated: `validate_checkpoint("S10")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, combat systems complete
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Combo detector reads input buffer from S02
- [ ] Button combos detected correctly (A+B, A+Down, etc.)
- [ ] Special moves only execute on Conductor upbeat
- [ ] Resource costs deducted (stamina/energy)
- [ ] Weapon-specific moves loaded from JSON
- [ ] Damage multipliers applied correctly
- [ ] Visual effects play for each special move
- [ ] Cooldowns prevent spam
- [ ] Integration with S07 weapons works
- [ ] Integration with S09 dodge (combo chains)

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ special_moves_system.gd complete with combo detection and upbeat gating
- ✅ special_moves.json complete with all move definitions
- ✅ HANDOFF-S10.md provides clear MCP agent instructions
- ✅ Upbeat timing integration implemented
- ✅ Weapon-specific moves system implemented
- ✅ Integration patterns documented for S01, S04, S07, S09

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Test scene configured correctly in Godot editor
- ✅ Combo detection works accurately
- ✅ Special moves only execute on upbeat
- ✅ Resource costs apply correctly
- ✅ Weapon-specific moves work
- ✅ Visual effects and damage multipliers work
- ✅ All verification criteria pass
- ✅ Combat system complete (S04-S10 all integrated)

</success_criteria>

<memory_checkpoint_format>
```
System S10 (Special Moves) Complete

FILES:
- res://combat/combo_detector.gd
- res://data/special_moves.json
- res://tests/test_special_moves.tscn

COMBO SYSTEM:
- Input buffer from S02
- 200ms combo window
- Upbeat execution only (S01)

RESOURCE COSTS:
- Stamina (from S09)
- Energy (new resource, max 50)

WEAPON-SPECIFIC MOVES:
- Sword: 2 moves
- Axe: 2 moves
- Staff: 2 moves
(20+ total moves)

STATUS: Combat systems complete (S04, S09, S10)
```
</memory_checkpoint_format>
