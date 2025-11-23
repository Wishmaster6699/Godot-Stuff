<objective>
Implement Comprehensive Puzzle System (S17) - 6 puzzle types (Environmental, Tool-based, Item-locked, Rhythmic, Physics-based, Multi-stage) with 20+ example puzzles.

DEPENDS ON: S03 (Player), S14 (Tools for tool-based puzzles)
FINAL WAVE 3 SYSTEM
</objective>

<context>
The Puzzle System provides Zelda-like puzzle mechanics across the game world. Puzzles use environmental objects, tools, items, rhythm timing, physics, and combinations thereof.

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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S17")`
- [ ] Quality gates: `check_quality_gates("S17")`
- [ ] Checkpoint validation: `validate_checkpoint("S17")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S17", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

## Web Research
- "Godot puzzle system architecture"
- "Zelda dungeon puzzle design"
- "Godot physics puzzle implementation"

## Implementation

### 1. Puzzle Base Class
Create `res://puzzles/puzzle_base.gd`:
```gdscript
class_name Puzzle

signal puzzle_solved

var solved = false
var puzzle_type: String  # environmental, tool, item, rhythm, physics, multi_stage

func check_solution():
  # Override in subclasses
  pass
```

### 2. Environmental Puzzles
Create `res://puzzles/environmental_puzzle.gd`:
- Push/pull blocks onto pressure plates
- Lever sequences
- Mirror/light reflection
- Switch timing

### 3. Tool-Based Puzzles
Create `res://puzzles/tool_puzzle.gd`:
- Grapple to unreachable switches
- Laser cuts specific patterns
- Roller blades activate speed-sensitive plates

### 4. Item-Locked Puzzles
Create `res://puzzles/item_puzzle.gd`:
- Require specific inventory items (keys, orbs)
- Check Inventory (S05) for required items
- Consume items on use

### 5. Rhythmic Puzzles
Create `res://puzzles/rhythm_puzzle.gd`:
- Hit beats in sequence to unlock
- Simon Says with rhythm timing
- Multi-beat patterns (4/4, 3/4)

### 6. Physics-Based Puzzles
Create `res://puzzles/physics_puzzle.gd`:
- Momentum-based (swing objects)
- Gravity puzzles (drop weights)
- Buoyancy (float/sink objects)

### 7. Multi-Stage Puzzles
Create `res://puzzles/multi_stage_puzzle.gd`:
- Combination of above types
- Stage 1 → Stage 2 → Stage 3 → Solved
- Resets if player fails any stage

### 8. Puzzle Database
Create `res://data/puzzles.json` with 20+ puzzles:
```json
{
  "puzzles": [
    {
      "id": "001_pressure_plates",
      "type": "environmental",
      "description": "Push 3 blocks onto plates",
      "solution": {
        "blocks_on_plates": ["block_a", "block_b", "block_c"]
      },
      "reward": { "item": "bronze_key" }
    }
  ]
}
```

### 9. Test Scene
- One puzzle of each type
- Visual feedback for puzzle state
- Reward display on solve

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://puzzles/puzzle_base.gd` - Base puzzle class with solve/reset logic
   - Individual puzzle type scripts (environmental, tool, item, rhythm, physics, multi_stage)
   - Complete implementations with full logic
   - Type hints, documentation, error handling
   - Integration with Tools (S14), Inventory (S05), Conductor (S01)

2. **Create all JSON data files** using the Write tool
   - `res://data/puzzles.json` - 20+ example puzzles with full configurations
   - Valid JSON format with all required fields

3. **Create HANDOFF-S17.md** documenting:
   - Scene structures needed (puzzle scenes, test environment)
   - MCP agent tasks (use GDAI tools)
   - Node hierarchies and property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- Puzzle scripts (base class + 6 puzzle types)
- `res://data/puzzles.json` - 20+ example puzzles
- `HANDOFF-S17.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S17.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create puzzle scenes, test_puzzles.tscn
   - `add_node` - Build node hierarchies (puzzle objects, triggers, rewards)
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set puzzle parameters, reward values
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S17.md` with this structure:

```markdown
# HANDOFF: S17 - Puzzle System

## Files Created by Claude Code Web

### GDScript Files
- `res://puzzles/puzzle_base.gd` - Base puzzle class
- `res://puzzles/environmental_puzzle.gd` - Push/pull, levers, mirrors
- `res://puzzles/tool_puzzle.gd` - Grapple, laser, blade puzzles
- `res://puzzles/item_puzzle.gd` - Key/orb locked puzzles
- `res://puzzles/rhythm_puzzle.gd` - Beat sequence puzzles
- `res://puzzles/physics_puzzle.gd` - Momentum, gravity, buoyancy
- `res://puzzles/multi_stage_puzzle.gd` - Combination puzzles

### Data Files
- `res://data/puzzles.json` - 20+ example puzzle configurations

## MCP Agent Tasks

### 1. Create Puzzle Scenes

Create example scenes for each puzzle type using the configurations in puzzles.json.

```bash
# Environmental puzzle example (push block onto button)
create_scene res://puzzles/examples/push_block_puzzle.tscn
add_node res://puzzles/examples/push_block_puzzle.tscn Node2D PushBlockPuzzle root
add_node res://puzzles/examples/push_block_puzzle.tscn StaticBody2D Block PushBlockPuzzle
add_node res://puzzles/examples/push_block_puzzle.tscn Area2D PressurePlate PushBlockPuzzle
add_node res://puzzles/examples/push_block_puzzle.tscn Node2D Door PushBlockPuzzle
attach_script res://puzzles/examples/push_block_puzzle.tscn PushBlockPuzzle res://puzzles/environmental_puzzle.gd

# Tool puzzle example (laser beam redirects)
create_scene res://puzzles/examples/laser_mirror_puzzle.tscn
add_node res://puzzles/examples/laser_mirror_puzzle.tscn Node2D LaserPuzzle root
add_node res://puzzles/examples/laser_mirror_puzzle.tscn Node2D LaserSource LaserPuzzle
add_node res://puzzles/examples/laser_mirror_puzzle.tscn Node2D Mirror1 LaserPuzzle
add_node res://puzzles/examples/laser_mirror_puzzle.tscn Node2D Mirror2 LaserPuzzle
add_node res://puzzles/examples/laser_mirror_puzzle.tscn Area2D Target LaserPuzzle
attach_script res://puzzles/examples/laser_mirror_puzzle.tscn LaserPuzzle res://puzzles/tool_puzzle.gd

# Rhythm puzzle example (beat sequence)
create_scene res://puzzles/examples/rhythm_lock_puzzle.tscn
add_node res://puzzles/examples/rhythm_lock_puzzle.tscn Node2D RhythmPuzzle root
add_node res://puzzles/examples/rhythm_lock_puzzle.tscn Control BeatDisplay RhythmPuzzle
add_node res://puzzles/examples/rhythm_lock_puzzle.tscn Node2D Lock RhythmPuzzle
attach_script res://puzzles/examples/rhythm_lock_puzzle.tscn RhythmPuzzle res://puzzles/rhythm_puzzle.gd
```

### 2. Create Test Scene

```bash
create_scene res://tests/test_puzzles.tscn
add_node res://tests/test_puzzles.tscn Node2D TestPuzzles root
add_node res://tests/test_puzzles.tscn PushBlockPuzzle Env1 TestPuzzles res://puzzles/examples/push_block_puzzle.tscn
add_node res://tests/test_puzzles.tscn LaserPuzzle Tool1 TestPuzzles res://puzzles/examples/laser_mirror_puzzle.tscn
add_node res://tests/test_puzzles.tscn RhythmPuzzle Rhythm1 TestPuzzles res://puzzles/examples/rhythm_lock_puzzle.tscn

# Position puzzles in test scene
update_property res://tests/test_puzzles.tscn Env1 position "Vector2(100, 100)"
update_property res://tests/test_puzzles.tscn Tool1 position "Vector2(400, 100)"
update_property res://tests/test_puzzles.tscn Rhythm1 position "Vector2(700, 100)"
```

## Testing Checklist

Use Godot MCP tools to test:

```bash
# Run test scene
play_scene res://tests/test_puzzles.tscn

# Check for errors
get_godot_errors
```

### Verify:
- [ ] Environmental puzzles: Push/pull blocks, levers, mirrors work
- [ ] Tool-based puzzles: Grapple, laser, blade mechanics work
- [ ] Item-locked puzzles: Key/orb requirements check inventory
- [ ] Rhythmic puzzles: Beat sequences unlock correctly
- [ ] Physics puzzles: Momentum, gravity, buoyancy work
- [ ] Multi-stage puzzles: Combinations solve correctly
- [ ] Rewards granted on solve (XP, items, unlocks)
- [ ] Puzzle reset functionality works
- [ ] 20+ example puzzles tested

### Integration Points:
- **S01 (Conductor)**: Rhythm puzzle beat timing
- **S05 (Inventory)**: Item-locked puzzle requirements
- **S14 (Tools)**: Tool-based puzzle mechanics

## Completion

When testing passes:
1. Update `COORDINATION-DASHBOARD.md`:
   - Mark S17 as "complete"
   - Release any resource locks
   - Unblock dependent systems
2. Run framework quality gates:
   - `IntegrationTestSuite.run_all_tests()`
   - `PerformanceProfiler.profile_system("S17")`
   - `check_quality_gates("S17")`
   - `validate_checkpoint("S17")`
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S17.md, verify:

### Code Quality
- [ ] puzzle_base.gd created with complete implementation (no TODOs or placeholders)
- [ ] All 6 puzzle type scripts created with full implementations
- [ ] puzzles.json created with valid JSON (20+ puzzles, no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling for puzzle solve/reset logic

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (puzzles/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S17.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used

### System-Specific Verification (File Creation)
- [ ] Puzzle base class with solve/reset logic
- [ ] Environmental puzzle implementation (push/pull, levers, mirrors)
- [ ] Tool-based puzzle implementation (grapple, laser, blades)
- [ ] Item-locked puzzle implementation (inventory checks)
- [ ] Rhythmic puzzle implementation (beat sequences)
- [ ] Physics puzzle implementation (momentum, gravity, buoyancy)
- [ ] Multi-stage puzzle implementation (combinations)
- [ ] 20+ example puzzles in JSON
- [ ] Reward system implementation
- [ ] Integration with Tools (S14), Inventory (S05), Conductor (S01) documented

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
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S17")`
- [ ] Quality gates passed: `check_quality_gates("S17")`
- [ ] Checkpoint validated: `validate_checkpoint("S17")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Puzzle base class instantiates correctly
- [ ] Environmental puzzles: Push/pull blocks, levers, mirrors work
- [ ] Tool-based puzzles: Grapple, laser, blade mechanics work
- [ ] Item-locked puzzles: Key/orb requirements check inventory correctly
- [ ] Rhythmic puzzles: Beat sequences unlock correctly with S01
- [ ] Physics puzzles: Momentum, gravity, buoyancy mechanics work
- [ ] Multi-stage puzzles: Combinations solve correctly
- [ ] 20+ example puzzles all tested and working
- [ ] Rewards granted on solve (XP, items, unlocks)
- [ ] Puzzle reset functionality works
- [ ] Integration with Tools (S14) works
- [ ] Integration with Inventory (S05) works
- [ ] Integration with Conductor (S01) works

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ puzzle_base.gd complete with solve/reset system
- ✅ All 6 puzzle type scripts complete with full implementations
- ✅ environmental_puzzle.gd with push/pull, levers, mirrors
- ✅ tool_puzzle.gd with grapple, laser, blade mechanics
- ✅ item_puzzle.gd with inventory requirement checks
- ✅ rhythm_puzzle.gd with beat sequence logic
- ✅ physics_puzzle.gd with momentum, gravity, buoyancy
- ✅ multi_stage_puzzle.gd with combination logic
- ✅ puzzles.json complete with 20+ example puzzles
- ✅ HANDOFF-S17.md provides clear MCP agent instructions
- ✅ Integration patterns documented for S01, S05, S14
- ✅ Zelda-like puzzle variety achieved

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ All puzzle scenes configured correctly in Godot editor
- ✅ Environmental puzzles work (push, pull, levers, mirrors)
- ✅ Tool puzzles integrate with S14 correctly
- ✅ Item puzzles check inventory (S05) correctly
- ✅ Rhythm puzzles sync with Conductor (S01)
- ✅ Physics puzzles demonstrate proper mechanics
- ✅ Multi-stage puzzles combine mechanics correctly
- ✅ All 20+ example puzzles tested and working
- ✅ Reward system grants XP, items, unlocks
- ✅ Puzzle reset works correctly
- ✅ All verification criteria pass
- ✅ Puzzle variety and quality meet Zelda standards

</success_criteria>

<memory_checkpoint_format>
```
System S17 (Puzzle System) Complete

FILES:
- res://puzzles/puzzle_base.gd
- res://puzzles/environmental_puzzle.gd
- res://puzzles/tool_puzzle.gd
- res://puzzles/item_puzzle.gd
- res://puzzles/rhythm_puzzle.gd
- res://puzzles/physics_puzzle.gd
- res://puzzles/multi_stage_puzzle.gd
- res://data/puzzles.json (20+ puzzles)
- res://tests/test_puzzles.tscn

PUZZLE TYPES:
1. Environmental (push/pull, levers, mirrors)
2. Tool-based (grapple, laser, blades)
3. Item-locked (keys, orbs from inventory)
4. Rhythmic (beat sequences)
5. Physics (momentum, gravity, buoyancy)
6. Multi-stage (combinations)

PUZZLE COUNT: 20+ example puzzles

INTEGRATION:
- Tools (S14) for tool puzzles
- Inventory (S05) for item-locked
- Conductor (S01) for rhythm puzzles

STATUS: Puzzle content complete
```
</memory_checkpoint_format>
