<objective>
Implement Dual XP System (S19) - separate Combat XP and Knowledge XP with different stat growth paths. Combat XP from enemy defeats, Knowledge XP from puzzles/discoveries/lore. Independent level-up for each type.

DEPENDS ON: S04 (Combat for XP gains), S17 (Puzzles for knowledge XP)
CAN RUN IN PARALLEL WITH: S24, S25, S26 (Wave 1 of Job 4)
</objective>

<context>
The Dual XP System splits character progression into two paths: Combat (physical prowess) and Knowledge (magical/intellectual). This allows players to specialize based on playstyle.

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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S19")`
- [ ] Quality gates: `check_quality_gates("S19")`
- [ ] Checkpoint validation: `validate_checkpoint("S19")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S19", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

## Web Research
- "RPG dual progression system design"
- "Godot XP leveling system"
- "Stat growth calculation formulas"

## Implementation

### 1. XP Manager
Create `res://systems/xp_manager.gd` (attached to Player):
```gdscript
var combat_xp = 0
var combat_level = 1
var knowledge_xp = 0
var knowledge_level = 1

signal combat_level_up(new_level)
signal knowledge_level_up(new_level)
```

### 2. XP Gain Sources
**Combat XP:**
- Enemy defeat: Base XP * enemy_level * difficulty_multiplier
- Perfect rhythm combat: +25% XP bonus
- Boss defeat: 5x regular XP

**Knowledge XP:**
- Puzzle solved: Puzzle_difficulty * 50 XP
- Lore item discovered: 100 XP
- NPC dialogue completion: 25 XP
- Map area discovered: 75 XP

### 3. Stat Growth Paths
Create `res://data/xp_config.json`:
```json
{
  "xp_config": {
    "combat_xp": {
      "level_curve": [100, 250, 500, 1000, 2000],
      "stat_growth_per_level": {
        "max_hp": 10,
        "physical_attack": 3,
        "physical_defense": 2,
        "speed": 1
      }
    },
    "knowledge_xp": {
      "level_curve": [100, 250, 500, 1000, 2000],
      "stat_growth_per_level": {
        "max_mp": 10,
        "special_attack": 3,
        "special_defense": 2,
        "magic_affinity": 1
      }
    },
    "xp_sources": {
      "enemy_defeat_base": 50,
      "puzzle_solved_base": 50,
      "lore_discovered": 100,
      "npc_dialogue": 25
    }
  }
}
```

### 4. Level-Up Calculation
```gdscript
func add_combat_xp(amount: int):
  combat_xp += amount
  check_combat_level_up()

func check_combat_level_up():
  var required = get_xp_for_level(combat_level)
  if combat_xp >= required:
    combat_level += 1
    apply_combat_stat_growth()
    combat_level_up.emit(combat_level)
```

### 5. Integration with Combat (S04)
Modify Combatant death:
```gdscript
func on_enemy_defeated(enemy):
  var xp = enemy.base_xp * enemy.level
  XPManager.add_combat_xp(xp)
```

### 6. Integration with Puzzles (S17)
Modify Puzzle solved:
```gdscript
func on_puzzle_solved(difficulty):
  var xp = difficulty * 50
  XPManager.add_knowledge_xp(xp)
```

### 7. Level-Up UI
Create `res://ui/level_up_panel.tscn`:
- Displays which type leveled up
- Shows stat increases
- Animates stat growth

### 8. Save Integration (S06)
Save both XP types and levels

### 9. Test Scene
- Enemy defeat grants combat XP
- Puzzle solve grants knowledge XP
- Level-up triggers correctly
- Stats increase per type

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://systems/xp_manager.gd` - Dual XP tracking and level-up system
   - `res://ui/level_up_panel.gd` - Level-up UI display
   - Complete implementations with full logic
   - Type hints, documentation, error handling
   - Integration with Combat (S04), Puzzles (S17), Save/Load (S06)

2. **Create all JSON data files** using the Write tool
   - `res://data/xp_config.json` - XP sources, level curves, stat bonuses
   - Valid JSON format with all required fields

3. **Create HANDOFF-S19.md** documenting:
   - Scene structures needed (level-up UI, test scene)
   - MCP agent tasks (use GDAI tools)
   - Node hierarchies and property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- XP system scripts (manager + UI)
- `res://data/xp_config.json` - Configuration data
- `HANDOFF-S19.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S19.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create level_up_panel.tscn, test_dual_xp.tscn
   - `add_node` - Build node hierarchies (UI elements, test components)
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set XP parameters, UI layout
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S19.md` with this structure:

```markdown
# HANDOFF: S19 - Dual XP System

## Files Created by Claude Code Web

### GDScript Files
- `res://systems/xp_manager.gd` - Dual XP tracking (Combat XP + Knowledge XP)
- `res://ui/level_up_panel.gd` - Level-up notification UI

### Data Files
- `res://data/xp_config.json` - XP sources, curves, stat bonuses

## MCP Agent Tasks

### 1. Create XP Manager Autoload

```bash
# Add to project settings as autoload "XPManager"
# Path: res://systems/xp_manager.gd
```

### 2. Create Level-Up UI

```bash
create_scene res://ui/level_up_panel.tscn
add_node res://ui/level_up_panel.tscn Panel LevelUpPanel root
add_node res://ui/level_up_panel.tscn Label TitleLabel LevelUpPanel
add_node res://ui/level_up_panel.tscn Label CombatLevelLabel LevelUpPanel
add_node res://ui/level_up_panel.tscn Label KnowledgeLevelLabel LevelUpPanel
add_node res://ui/level_up_panel.tscn VBoxContainer StatsContainer LevelUpPanel
attach_script res://ui/level_up_panel.tscn LevelUpPanel res://ui/level_up_panel.gd

update_property res://ui/level_up_panel.tscn TitleLabel text "LEVEL UP!"
update_property res://ui/level_up_panel.tscn LevelUpPanel visible false
```

### 3. Create Test Scene

```bash
create_scene res://tests/test_dual_xp.tscn
add_node res://tests/test_dual_xp.tscn Node2D TestDualXP root
add_node res://tests/test_dual_xp.tscn Button GrantCombatXP TestDualXP
add_node res://tests/test_dual_xp.tscn Button GrantKnowledgeXP TestDualXP
add_node res://tests/test_dual_xp.tscn Label CombatXPDisplay TestDualXP
add_node res://tests/test_dual_xp.tscn Label KnowledgeXPDisplay TestDualXP
add_node res://tests/test_dual_xp.tscn LevelUpPanel LevelUpUI TestDualXP res://ui/level_up_panel.tscn

update_property res://tests/test_dual_xp.tscn GrantCombatXP text "Grant Combat XP (+100)"
update_property res://tests/test_dual_xp.tscn GrantKnowledgeXP text "Grant Knowledge XP (+100)"
update_property res://tests/test_dual_xp.tscn GrantCombatXP position "Vector2(50, 50)"
update_property res://tests/test_dual_xp.tscn GrantKnowledgeXP position "Vector2(50, 100)"
```

## Testing Checklist

Use Godot MCP tools to test:

```bash
# Run test scene
play_scene res://tests/test_dual_xp.tscn

# Check for errors
get_godot_errors
```

### Verify:
- [ ] Combat XP increases on enemy defeat
- [ ] Knowledge XP increases on puzzle solve
- [ ] Combat level-up applies HP/Physical stats correctly
- [ ] Knowledge level-up applies MP/Special stats correctly
- [ ] Level curves work (exponential growth)
- [ ] Perfect rhythm combat gives +25% XP bonus
- [ ] XP sources configurable from JSON
- [ ] Level-up UI displays correctly
- [ ] Both XP types track independently
- [ ] Stat bonuses apply correctly per XP type

### Integration Points:
- **S04 (Combat)**: Grant Combat XP on enemy defeat
- **S17 (Puzzles)**: Grant Knowledge XP on puzzle solve
- **S06 (Save/Load)**: Persist both XP values and levels

## Completion

When testing passes:
1. Update `COORDINATION-DASHBOARD.md`:
   - Mark S19 as "complete"
   - Release any resource locks
   - Unblock dependent systems
2. Run framework quality gates:
   - `IntegrationTestSuite.run_all_tests()`
   - `PerformanceProfiler.profile_system("S19")`
   - `check_quality_gates("S19")`
   - `validate_checkpoint("S19")`
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S19.md, verify:

### Code Quality
- [ ] xp_manager.gd created with complete implementation (no TODOs or placeholders)
- [ ] level_up_panel.gd created with UI display logic
- [ ] xp_config.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling for XP calculation and level-up

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (systems/, ui/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S19.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used

### System-Specific Verification (File Creation)
- [ ] Dual XP tracking (Combat XP + Knowledge XP)
- [ ] Level curve calculation for both types
- [ ] Stat bonus application (HP/Physical vs MP/Special)
- [ ] Perfect rhythm XP bonus (+25%) implementation
- [ ] XP source configuration in JSON
- [ ] Integration with S04, S17, S06 documented

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
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S19")`
- [ ] Quality gates passed: `check_quality_gates("S19")`
- [ ] Checkpoint validated: `validate_checkpoint("S19")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Combat XP increases on enemy defeat (S04 integration)
- [ ] Knowledge XP increases on puzzle solve (S17 integration)
- [ ] Combat level-up applies HP/Physical stats correctly
- [ ] Knowledge level-up applies MP/Special stats correctly
- [ ] Level curves work (exponential growth per type)
- [ ] Perfect rhythm combat gives +25% XP bonus
- [ ] XP sources configurable from JSON
- [ ] Level-up UI displays correctly with stat increases
- [ ] Both XP types track independently
- [ ] Save/Load (S06) persists both XP types

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ xp_manager.gd complete with dual XP tracking system
- ✅ Combat XP and Knowledge XP track independently
- ✅ Level curve calculations for both types
- ✅ Stat bonus application logic (HP/Physical vs MP/Special)
- ✅ Perfect rhythm XP bonus implementation (+25%)
- ✅ level_up_panel.gd complete with UI display
- ✅ xp_config.json complete with all XP sources and curves
- ✅ HANDOFF-S19.md provides clear MCP agent instructions
- ✅ Integration patterns documented for S04, S17, S06

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ XP Manager autoload configured correctly
- ✅ Level-up UI displays correctly
- ✅ Combat XP system works (enemy defeats)
- ✅ Knowledge XP system works (puzzle solves)
- ✅ Combat levels increase HP and Physical stats
- ✅ Knowledge levels increase MP and Special stats
- ✅ Level curves balanced and functional
- ✅ Perfect rhythm bonus applies correctly
- ✅ Both XP types saved and loaded correctly
- ✅ All verification criteria pass
- ✅ Dual progression system adds strategic depth

</success_criteria>

<memory_checkpoint_format>
```
System S19 (Dual XP) Complete

FILES:
- res://systems/xp_manager.gd
- res://data/xp_config.json
- res://ui/level_up_panel.tscn
- res://tests/test_dual_xp.tscn

DUAL XP PATHS:
- Combat XP → HP, Physical Attack, Physical Defense, Speed
- Knowledge XP → MP, Special Attack, Special Defense, Magic Affinity

XP SOURCES:
- Combat: Enemy defeats (50 base * level * difficulty)
- Knowledge: Puzzles (difficulty * 50), Lore (100), Dialogue (25)

LEVEL CURVES:
- Level 1→2: 100 XP
- Level 2→3: 250 XP
- Level 3→4: 500 XP
(Exponential growth)

INTEGRATION:
- Combat (S04) awards combat XP
- Puzzles (S17) award knowledge XP
- Save/Load (S06) persists progress
- Ready for S20 (Evolution uses levels)

STATUS: Ready for S20
```
</memory_checkpoint_format>
