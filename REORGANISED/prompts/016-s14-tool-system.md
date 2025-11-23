<objective>
Implement Tool System (S14) - real-time switchable tools (Grapple Hook, Laser, Roller Blades, Surfboard) with instant switching, tool-specific mechanics, and puzzle integration.

DEPENDS ON: S03 (Player Controller)
CAN RUN IN PARALLEL WITH: S09, S11, S13, S15, S16, S18
</objective>

<context>
Tools extend player abilities beyond combat. Each tool has unique mechanics for traversal and puzzle-solving. Tools can be switched instantly during gameplay.

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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S14")`
- [ ] Quality gates: `check_quality_gates("S14")`
- [ ] Checkpoint validation: `validate_checkpoint("S14")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S14", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

## Web Research
- "Godot grappling hook implementation"
- "Godot state machine for abilities"
- "Zelda-like tool system design"

## Implementation

### 1. Tool Manager
Create `res://player/tool_manager.gd` (attached to Player):
- Current tool: String (grapple/laser/blades/surfboard)
- Switch tool: D-pad or shoulder buttons
- Tool slot UI display

### 2. Grapple Hook
Create `res://tools/grapple_hook.gd`:
- Raycast to detect grapple points
- Swing physics (pendulum)
- Max range: 200px
- Release: Jump button

### 3. Laser
Create `res://tools/laser.gd`:
- Continuous beam (hold button)
- Cuts destructible objects
- Raycast damage to enemies
- Overheats after 3s use

### 4. Roller Blades
Create `res://tools/roller_blades.gd`:
- Speed boost: 2x normal speed
- Rhythm balance mini-game on rough terrain
- Can't attack while skating

### 5. Surfboard
Create `res://tools/surfboard.gd`:
- Water traversal
- Auto-activates on water tiles
- Wave physics (bob up/down)

### 6. Tool Configuration
Create `res://data/tools_config.json`:
```json
{
  "tools": {
    "grapple_hook": {
      "max_range": 200,
      "swing_force": 500,
      "cooldown_s": 0.5
    },
    "laser": {
      "damage_per_second": 15,
      "max_duration_s": 3.0,
      "overheat_cooldown_s": 2.0
    },
    "roller_blades": {
      "speed_multiplier": 2.0,
      "balance_difficulty": 0.3
    },
    "surfboard": {
      "water_speed": 150,
      "wave_amplitude": 10
    }
  }
}
```

### 7. Tool Switching UI
- Tool icons (bottom right)
- Current tool highlighted
- Cooldown visual

### 8. Test Scene
- Test area with grapple points, destructible walls, water
- Tool switching test
- Each tool mechanic demonstration

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://tools/tool_manager.gd` - Tool switching system, tool states
   - Individual tool scripts (grapple_hook.gd, laser.gd, roller_blades.gd, surfboard.gd)
   - Complete implementations with full logic
   - Type hints, documentation, error handling
   - Integration with Player (S03)

2. **Create all JSON data files** using the Write tool
   - `res://data/tools_config.json` - Tool parameters, cooldowns, abilities
   - Valid JSON format with all required fields

3. **Create HANDOFF-S14.md** documenting:
   - Scene structures needed (tool scenes, test environment)
   - MCP agent tasks (use GDAI tools)
   - Node hierarchies and property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- Tool scripts (manager + 4 individual tools)
- `res://data/tools_config.json` - Configuration data
- `HANDOFF-S14.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S14.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create tool scenes, test_tools.tscn
   - `add_node` - Build node hierarchies (tool nodes, physics components)
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set tool properties, physics parameters
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S14.md` with the structure shown in HANDOFF-S01.md, adapted for:
- System ID: S14
- System Name: Tool System
- GDScript files: res://tools/tool_manager.gd, individual tool scripts
- Data files: res://data/tools_config.json
- Test scenes: res://tests/test_tools.tscn
- Autoload: None (attached to Player)
- Dependencies: S03 (Player Controller)
- Depended on by: S17 (Puzzle System)
- Key signals: tool_switched(tool_id), tool_used(tool_id)
- Key methods: switch_tool(), use_current_tool()
- Testing focus: Tool switching speed, tool-specific mechanics, puzzle integration

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S14.md, verify:

### Code Quality
- [ ] tool_manager.gd created with complete implementation (no TODOs or placeholders)
- [ ] All tool scripts created (grapple_hook.gd, laser.gd, roller_blades.gd, surfboard.gd)
- [ ] tools_config.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling for tool switching and usage

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (tools/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S14.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used

### System-Specific Verification (File Creation)
- [ ] Tool manager with switch_tool() and use_current_tool() methods
- [ ] Grapple hook with raycast and swing physics logic
- [ ] Laser with raycast damage and overheat mechanics
- [ ] Roller blades with speed boost and balance mechanics
- [ ] Surfboard with water detection and wave physics
- [ ] Tool configuration data complete in JSON
- [ ] Integration with Player (S03) documented

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
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S14")`
- [ ] Quality gates passed: `check_quality_gates("S14")`
- [ ] Checkpoint validated: `validate_checkpoint("S14")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Tool Manager switches between 4 tools instantly (<0.1s)
- [ ] Grapple Hook: Raycasts to grapple points, swings player correctly
- [ ] Laser: Cuts destructible objects, damages enemies, overheats after 3s
- [ ] Roller Blades: 2x speed works, rhythm balance mini-game on rough terrain
- [ ] Surfboard: Auto-activates on water, wave physics bob up/down
- [ ] Tool switching UI shows current tool and cooldowns
- [ ] Integration with Player (S03) works correctly
- [ ] All tools respond to input correctly
- [ ] Ready for S17 (Puzzle System) tool-based puzzles

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ tool_manager.gd complete with tool switching logic
- ✅ grapple_hook.gd complete with raycast and swing physics
- ✅ laser.gd complete with damage and overheat mechanics
- ✅ roller_blades.gd complete with speed boost and balance mechanics
- ✅ surfboard.gd complete with water detection and wave physics
- ✅ tools_config.json complete with all tool parameters
- ✅ HANDOFF-S14.md provides clear MCP agent instructions
- ✅ Integration patterns documented for S03 (Player)
- ✅ Ready for S17 (Puzzle System) integration

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ All tool scenes configured correctly in Godot editor
- ✅ Tool switching works instantly (<0.1s)
- ✅ Grapple hook swings correctly with proper physics
- ✅ Laser cuts and damages with overheat mechanic
- ✅ Roller blades provide speed boost with balance mini-game
- ✅ Surfboard activates on water with wave physics
- ✅ Tool UI displays correctly with cooldowns
- ✅ Integration with Player (S03) works
- ✅ All verification criteria pass
- ✅ Ready for puzzle integration (S17)

</success_criteria>

<memory_checkpoint_format>
```
System S14 (Tool System) Complete

FILES:
- res://player/tool_manager.gd
- res://tools/grapple_hook.gd
- res://tools/laser.gd
- res://tools/roller_blades.gd
- res://tools/surfboard.gd
- res://data/tools_config.json
- res://tests/test_tools.tscn

TOOLS:
- Grapple Hook: Swing, range 200px
- Laser: Cut/damage, 3s max duration
- Roller Blades: 2x speed, rhythm balance
- Surfboard: Water traversal, wave physics

TOOL SWITCHING:
- Instant switching (D-pad or shoulder buttons)
- UI display with cooldowns

INTEGRATION:
- Extends Player (S03) abilities
- Ready for S17 (Puzzle System) tool puzzles

STATUS: Traversal tools complete, ready for S17
```
</memory_checkpoint_format>
