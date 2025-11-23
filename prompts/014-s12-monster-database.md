<objective>
Implement 100+ Monster Database (S12) with evolution system (stages 1-5), type system (12 types), type effectiveness matrix, and complete monster data (stats, moves, abilities, loot).

DEPENDS ON: S04 (Combat), S11 (Enemy AI for behavior assignment)
FINAL WAVE 2 SYSTEM
</objective>

<context>
The Monster Database is the content heart of the game. 100+ monsters with Pokemon-style type system and evolution stages. Each monster has stats, moves, AI behavior, and loot table.

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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S12")`
- [ ] Quality gates: `check_quality_gates("S12")`
- [ ] Checkpoint validation: `validate_checkpoint("S12")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S12", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<file_isolation>

## 🚨 FILE ISOLATION RULES - PREVENT MERGE CONFLICTS

**System ID:** S12 | **System Name:** Monster Database

**✅ YOU MAY MODIFY:**
```
src/systems/s12-monsters/
scenes/s12-monsters/
checkpoints/s12-monsters-checkpoint.md
research/s12-monsters-research.md
HANDOFF-S12-MONSTERS.md
```

**❌ YOU MUST NOT MODIFY:** Other systems' directories, `src/core/`, `project.godot`

**See `GIT-WORKFLOW.md` for complete file isolation rules.**

</file_isolation>

<requirements>

## Web Research
- "Pokemon type effectiveness system"
- "Monster evolution system design"
- "Godot resource-based database"

## Implementation

### 1. Monster Resource Class
Create `res://resources/monster_resource.gd`:
```gdscript
extends Resource
class_name MonsterResource

@export var id: String
@export var name: String
@export var types: Array[String]  # ["fire", "flying"]
@export var evolution_stage: int  # 1-5
@export var base_stats: Dictionary
@export var moves: Array[String]  # Move IDs
@export var abilities: Array[String]
@export var ai_behavior_type: String  # From S11
@export var loot_table: Dictionary
@export var evolution_requirements: Dictionary
```

### 2. Type System (12 Types)
Types: Normal, Fire, Water, Grass, Electric, Ice, Fighting, Poison, Ground, Flying, Psychic, Dark

Create `res://data/type_effectiveness.json`:
```json
{
  "type_chart": {
    "fire": {
      "super_effective": ["grass", "ice"],
      "not_very_effective": ["water", "fire"],
      "immune": []
    }
  }
}
```

### 3. Monster Database
Create `res://data/monsters.json` with 100+ entries:
```json
{
  "monsters": [
    {
      "id": "001_sparkle",
      "name": "Sparkle",
      "types": ["electric"],
      "evolution_stage": 1,
      "base_stats": {
        "hp": 45,
        "attack": 49,
        "defense": 49,
        "speed": 45
      },
      "moves": ["tackle", "thunder_shock"],
      "abilities": ["static"],
      "ai_behavior_type": "aggressive",
      "loot_table": {
        "common": ["electric_shard"],
        "rare": ["thunder_stone"],
        "drop_chance": 0.3
      },
      "evolution_requirements": {
        "level": 16,
        "evolves_into": "002_voltix"
      }
    }
  ]
}
```

### 4. Evolution System
Create `res://systems/evolution_system.gd`:
- Level-based evolution
- Item-based evolution (use Thunder Stone on Sparkle)
- Soul Shard evolution (from crafting)

### 5. Monster Autoload
Create `res://autoloads/monster_database.gd`:
- Loads monsters.json
- get_monster(id) -> MonsterResource
- get_monsters_by_type(type) -> Array
- calculate_type_effectiveness(attacker_type, defender_type) -> float

### 6. Integration with S11
Assign AI behavior to each monster:
- Aggressive monsters use aggressive behavior tree
- Defensive monsters use defensive behavior tree

### 7. Test Scene
- Display all 100+ monsters in grid
- Show stats, types, moves
- Evolution tree visualization
- Type effectiveness calculator

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://resources/monster_resource.gd` - MonsterResource class definition
   - `res://autoloads/monster_database.gd` - MonsterDatabase singleton for loading monsters
   - Type effectiveness calculator
   - Complete implementations with full logic
   - Type hints, documentation, error handling

2. **Create all JSON data files** using the Write tool
   - `res://data/monsters.json` - 100+ monster definitions with stats, types, moves, evolution
   - `res://data/type_effectiveness.json` - Type effectiveness matrix (12x12)
   - Valid JSON format with all required fields

3. **Create HANDOFF-S12.md** documenting:
   - Minimal scene needs (test scene for monster display)
   - MCP agent tasks (use GDAI tools)
   - Autoload registration instructions
   - Testing steps for MCP agent

### Your Deliverables:
- `res://resources/monster_resource.gd` - MonsterResource class
- `res://autoloads/monster_database.gd` - MonsterDatabase singleton
- `res://data/monsters.json` - Complete monsters database (100+ monsters)
- `res://data/type_effectiveness.json` - Type effectiveness matrix
- `HANDOFF-S12.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)
- Register autoload in project settings (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S12.md
2. Use GDAI tools to configure:
   - Register MonsterDatabase as autoload in project settings
   - `create_scene` - Create test_monsters.tscn for displaying monsters
   - Verify JSON files load correctly
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S12.md` with this structure:

```markdown
# HANDOFF: S12 - Monster Database

## Files Created by Claude Code Web

### GDScript Files
- `res://resources/monster_resource.gd` - MonsterResource class definition
- `res://autoloads/monster_database.gd` - MonsterDatabase singleton for loading/querying monsters
- `res://systems/evolution_system.gd` - Evolution system logic

### Data Files
- `res://data/monsters.json` - 100+ monster definitions with stats, types, moves, evolution
- `res://data/type_effectiveness.json` - Type effectiveness matrix (12x12)

## MCP Agent Tasks

### 1. Register MonsterDatabase Autoload

```bash
# Register MonsterDatabase as autoload in project settings
set_project_setting autoload/MonsterDatabase "*res://autoloads/monster_database.gd"

# Verify autoload registration
get_project_setting autoload/MonsterDatabase
```

### 2. Create Test Monster Display Scene

```bash
# Create test scene for monster display
create_scene res://tests/test_monsters.tscn
add_node res://tests/test_monsters.tscn Node2D TestMonsters root
add_node res://tests/test_monsters.tscn CanvasLayer UI TestMonsters

# Add monster grid display
add_node res://tests/test_monsters.tscn ScrollContainer MonsterScroll UI
add_node res://tests/test_monsters.tscn GridContainer MonsterGrid MonsterScroll

# Add type effectiveness calculator
add_node res://tests/test_monsters.tscn Panel TypeCalcPanel UI
add_node res://tests/test_monsters.tscn VBoxContainer TypeCalcLayout TypeCalcPanel
add_node res://tests/test_monsters.tscn Label TypeCalcTitle TypeCalcLayout
add_node res://tests/test_monsters.tscn HBoxContainer TypeInputs TypeCalcLayout
add_node res://tests/test_monsters.tscn OptionButton AttackerTypeSelect TypeInputs
add_node res://tests/test_monsters.tscn Label VsLabel TypeInputs
add_node res://tests/test_monsters.tscn OptionButton DefenderTypeSelect TypeInputs
add_node res://tests/test_monsters.tscn Label EffectivenessResult TypeCalcLayout

# Add evolution tree viewer
add_node res://tests/test_monsters.tscn Panel EvolutionPanel UI
add_node res://tests/test_monsters.tscn VBoxContainer EvolutionLayout EvolutionPanel
add_node res://tests/test_monsters.tscn Label EvolutionTitle EvolutionLayout
add_node res://tests/test_monsters.tscn Tree EvolutionTree EvolutionLayout

# Add monster info display
add_node res://tests/test_monsters.tscn Panel MonsterInfoPanel UI
add_node res://tests/test_monsters.tscn VBoxContainer MonsterInfoLayout MonsterInfoPanel
add_node res://tests/test_monsters.tscn Label MonsterName MonsterInfoLayout
add_node res://tests/test_monsters.tscn Label MonsterID MonsterInfoLayout
add_node res://tests/test_monsters.tscn Label MonsterTypes MonsterInfoLayout
add_node res://tests/test_monsters.tscn Label MonsterStage MonsterInfoLayout
add_node res://tests/test_monsters.tscn Label MonsterStats MonsterInfoLayout
add_node res://tests/test_monsters.tscn Label MonsterMoves MonsterInfoLayout
add_node res://tests/test_monsters.tscn Label MonsterAbilities MonsterInfoLayout
add_node res://tests/test_monsters.tscn Label MonsterAI MonsterInfoLayout

# Add test controls
add_node res://tests/test_monsters.tscn VBoxContainer TestControls UI
add_node res://tests/test_monsters.tscn Label Instructions TestControls
add_node res://tests/test_monsters.tscn Button LoadAllButton TestControls
add_node res://tests/test_monsters.tscn Button FilterFireButton TestControls
add_node res://tests/test_monsters.tscn Button FilterWaterButton TestControls
add_node res://tests/test_monsters.tscn Label MonsterCount TestControls
```

### 3. Configure Test Scene Properties

```bash
# Grid configuration for monster display
update_property res://tests/test_monsters.tscn MonsterScroll custom_minimum_size "Vector2(800, 500)"
update_property res://tests/test_monsters.tscn MonsterScroll anchor_preset 15
update_property res://tests/test_monsters.tscn MonsterGrid columns 6

# Type effectiveness calculator
update_property res://tests/test_monsters.tscn TypeCalcPanel position "Vector2(820, 10)"
update_property res://tests/test_monsters.tscn TypeCalcPanel custom_minimum_size "Vector2(250, 150)"
update_property res://tests/test_monsters.tscn TypeCalcTitle text "Type Effectiveness"
update_property res://tests/test_monsters.tscn TypeCalcTitle horizontal_alignment 1
update_property res://tests/test_monsters.tscn VsLabel text "vs"
update_property res://tests/test_monsters.tscn EffectivenessResult text "Effectiveness: 1.0x"

# Evolution tree
update_property res://tests/test_monsters.tscn EvolutionPanel position "Vector2(820, 170)"
update_property res://tests/test_monsters.tscn EvolutionPanel custom_minimum_size "Vector2(250, 200)"
update_property res://tests/test_monsters.tscn EvolutionTitle text "Evolution Chains"
update_property res://tests/test_monsters.tscn EvolutionTitle horizontal_alignment 1

# Monster info panel
update_property res://tests/test_monsters.tscn MonsterInfoPanel position "Vector2(820, 380)"
update_property res://tests/test_monsters.tscn MonsterInfoPanel custom_minimum_size "Vector2(250, 300)"
update_property res://tests/test_monsters.tscn MonsterName text "Select a monster"
update_property res://tests/test_monsters.tscn MonsterID text "ID: ---"
update_property res://tests/test_monsters.tscn MonsterTypes text "Types: ---"
update_property res://tests/test_monsters.tscn MonsterStage text "Stage: ---"
update_property res://tests/test_monsters.tscn MonsterStats text "Stats: ---"
update_property res://tests/test_monsters.tscn MonsterMoves text "Moves: ---"
update_property res://tests/test_monsters.tscn MonsterAbilities text "Abilities: ---"
update_property res://tests/test_monsters.tscn MonsterAI text "AI: ---"

# Test controls
update_property res://tests/test_monsters.tscn TestControls position "Vector2(10, 520)"
update_property res://tests/test_monsters.tscn Instructions text "Test Monster Database: View 100+ monsters, test type effectiveness"
update_property res://tests/test_monsters.tscn LoadAllButton text "Load All Monsters"
update_property res://tests/test_monsters.tscn FilterFireButton text "Filter: Fire Type"
update_property res://tests/test_monsters.tscn FilterWaterButton text "Filter: Water Type"
update_property res://tests/test_monsters.tscn MonsterCount text "Monsters Loaded: 0"
```

### 4. Verify JSON Files Load

```bash
# Test JSON file loading (run in Godot console or test script)
# MonsterDatabase.get_monster("001_sparkle")
# MonsterDatabase.get_type_effectiveness("fire", "grass")
# MonsterDatabase.get_monsters_by_type("electric")
```

## Testing Checklist

Use Godot MCP tools to test:

```bash
# Run test scene
play_scene res://tests/test_monsters.tscn

# Check for errors
get_godot_errors
```

### Verify:
- [ ] MonsterDatabase autoload registered and accessible globally
- [ ] monsters.json loads without JSON parse errors
- [ ] type_effectiveness.json loads without JSON parse errors
- [ ] 100+ monsters loaded (check monster count display)
- [ ] MonsterResource class instantiates correctly
- [ ] get_monster(id) returns correct MonsterResource (test with "001_sparkle")
- [ ] Monster grid displays all monsters
- [ ] Type effectiveness calculator works (fire vs grass = 2.0x)
- [ ] Type effectiveness: super effective, not very effective, immune
- [ ] 12 types defined: normal, fire, water, grass, electric, ice, fighting, poison, ground, flying, psychic, dark
- [ ] Evolution chains display correctly (stage 1-5)
- [ ] Evolution requirements shown (level, item, soul shard)
- [ ] AI behavior types assigned to each monster (aggressive, defensive, ranged, swarm)
- [ ] Loot tables defined for each monster (common/rare drops)
- [ ] Monster stats complete: HP, attack, defense, speed
- [ ] Monster moves list populated
- [ ] Monster abilities list populated
- [ ] Integration with S11: AI behavior types match enemy AI behaviors
- [ ] No errors in console when loading database

### Integration Points:
- **S04 (Combat)**: Monster stats used in combat calculations
- **S11 (Enemy AI)**: AI behavior types assigned to monsters
- **S20 (Evolution System)**: Evolution requirements and chains
- **S21 (Resonance Alignment)**: Type-based resonance bonuses

## Completion

Update COORDINATION-DASHBOARD.md:
- Mark S12 as complete
- Mark Wave 2 (S09-S12) as complete
- Unblock S20 (Evolution System) and S21 (Resonance Alignment)
- Release any resource locks
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S12.md, verify:

### Code Quality
- [ ] All .gd files created with complete implementations (no TODOs or placeholders)
- [ ] monsters.json and type_effectiveness.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for classes and methods
- [ ] Error handling implemented where needed

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (resources/, autoloads/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schemas are complete and validated
- [ ] HANDOFF-S12.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used

### System-Specific Verification (File Creation)
- [ ] MonsterResource class with all required fields (stats, types, moves, evolution, AI, loot)
- [ ] MonsterDatabase with loading logic and query methods
- [ ] monsters.json contains 100+ monster definitions
- [ ] type_effectiveness.json contains 12x12 type matrix
- [ ] Evolution chains complete for all evolution lines
- [ ] All monsters have complete data (no missing fields)

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] MonsterDatabase registered as autoload in project settings
- [ ] Test scene created using `create_scene`
- [ ] Verify JSON files parse without errors

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S12")`
- [ ] Quality gates passed: `check_quality_gates("S12")`
- [ ] Checkpoint validated: `validate_checkpoint("S12")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, Wave 2 complete
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] MonsterResource class loads from JSON
- [ ] MonsterDatabase autoload loads 100+ monsters
- [ ] 12 types defined in type_effectiveness.json
- [ ] Type effectiveness calculations work (fire beats grass)
- [ ] Evolution stages 1-5 defined for evolution lines
- [ ] AI behavior types assigned to monsters
- [ ] Loot tables defined for each monster
- [ ] Evolution system triggers at correct level/item
- [ ] get_monster(id) returns correct MonsterResource
- [ ] Integration with S11 AI works

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ MonsterResource and MonsterDatabase classes complete
- ✅ monsters.json complete with 100+ monster definitions
- ✅ type_effectiveness.json complete with 12x12 type matrix
- ✅ HANDOFF-S12.md provides clear MCP agent instructions
- ✅ All evolution chains complete
- ✅ All data schemas validated and extensible

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ MonsterDatabase registered as autoload and accessible globally
- ✅ All JSON files load without errors
- ✅ 100+ monsters loaded and accessible
- ✅ Type effectiveness calculations accurate
- ✅ Evolution chains work correctly
- ✅ All verification criteria pass
- ✅ Wave 2 complete (S09-S12 all integrated)
- ✅ System ready for dependent systems (S20, S21)

</success_criteria>

<memory_checkpoint_format>
```
System S12 (Monster Database) Complete

FILES:
- res://resources/monster_resource.gd
- res://autoloads/monster_database.gd
- res://systems/evolution_system.gd
- res://data/monsters.json (100+ monsters)
- res://data/type_effectiveness.json
- res://tests/test_monsters.tscn

MONSTER COUNT: 100+ unique monsters

TYPES: 12 types with effectiveness matrix

EVOLUTION STAGES: 1-5
- Level-based, item-based, soul shard-based

AI INTEGRATION:
- Each monster assigned behavior type from S11

LOOT SYSTEM:
- Common/rare drops
- Drop chances per monster

EXTENSIBILITY:
- Add new monster: Add JSON entry
- Add new type: Update type_effectiveness.json

STATUS: Monster content complete, ready for S20 (Evolution triggers)
```
</memory_checkpoint_format>
