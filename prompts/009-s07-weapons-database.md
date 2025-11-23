<objective>
Implement Weapons & Shields Database (S07) - data-driven weapon and shield definitions (50+ items) with JSON. Each weapon has damage, speed, range, attack patterns, special effects. Shields have defense, block percentage, special properties. Extensible for crafting (S25).

DEPENDS ON: S04 (Combat), S05 (Inventory)
BLOCKS: S08 (Equipment), S10 (Special Moves), S25 (Crafting)
</objective>

<context>
This system creates a comprehensive database of 50+ weapons and 15+ shields, all defined in JSON. These definitions will be used by:
- **S08**: Equipment System (for equipping weapons/shields)
- **S10**: Special Moves (weapon-specific special attacks)
- **S25**: Crafting (weapon enhancement and creation)

All weapon/shield stats are data-driven for easy balancing and expansion.

Reference:
@rhythm-rpg-implementation-guide.md (lines 856-1023 for S07 specification)
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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S07")`
- [ ] Quality gates: `check_quality_gates("S07")`
- [ ] Checkpoint validation: `validate_checkpoint("S07")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S07", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<file_isolation>

## 🚨 FILE ISOLATION RULES - PREVENT MERGE CONFLICTS

**System ID:** S07 | **System Name:** Weapons

**✅ YOU MAY MODIFY:**
```
src/systems/s07-weapons/
scenes/s07-weapons/
checkpoints/s07-weapons-checkpoint.md
research/s07-weapons-research.md
HANDOFF-S07-WEAPONS.md
```

**❌ YOU MUST NOT MODIFY:** Other systems' directories, `src/core/`, `project.godot`

**See `GIT-WORKFLOW.md` for complete file isolation rules.**

</file_isolation>

<requirements>

## Web Research First
- "Godot 4.5 custom resources best practices"
- "Godot 4.5 JSON data loading"
- Study weapon balancing from similar RPGs

## Implementation Tasks

### 1. Weapon Resource Class
Create `res://resources/weapon_resource.gd`:
```gdscript
extends Resource
class_name WeaponResource

@export var id: String
@export var name: String
@export var type: String  # sword, axe, spear, bow, staff
@export var tier: int
@export var damage: int
@export var speed: float
@export var range: int
@export var attack_pattern: String
@export var special_effects: Array[String]
@export var icon_path: String
@export var value: int
```

### 2. Shield Resource Class
Create `res://resources/shield_resource.gd`:
```gdscript
extends Resource
class_name ShieldResource

@export var id: String
@export var name: String
@export var type: String  # small, medium, large
@export var tier: int
@export var defense: int
@export var block_percentage: float
@export var weight: float
@export var special_properties: Array[String]
@export var icon_path: String
@export var value: int
```

### 3. Weapons Database JSON
Create `res://data/weapons.json` with 50+ weapons:
- 10 swords (wooden_sword, iron_sword, flame_sword, etc.)
- 8 axes
- 8 spears
- 8 bows
- 8 staves
- 8+ unique/legendary weapons

Example:
```json
{
  "weapons": [
    {
      "id": "wooden_sword",
      "name": "Wooden Sword",
      "type": "sword",
      "tier": 1,
      "damage": 8,
      "speed": 1.2,
      "range": 32,
      "attack_pattern": "slash",
      "special_effects": [],
      "icon_path": "res://assets/icons/weapons/wooden_sword.png",
      "value": 10
    }
  ]
}
```

### 4. Shields Database JSON
Create `res://data/shields.json` with 15+ shields:
- 5 small shields
- 5 medium shields
- 5 large shields

### 5. ItemDatabase Autoload
Create `res://autoloads/item_database.gd`:
- Singleton autoload
- Loads weapons.json and shields.json at startup
- Caches all WeaponResource and ShieldResource instances
- Methods: `get_weapon(id)`, `get_shield(id)`, `get_all_weapons()`, `get_all_shields()`

### 6. Integration with Combat (S04)
- Extend Combatant class to use weapon damage in damage calculation
- Update combat_config.json to reference weapon modifiers

### 7. Integration with Inventory (S05)
- Add weapon/shield type checking to inventory
- Display weapon/shield icons in inventory UI

### 8. Test Scene
Create `res://tests/test_weapons.tscn`:
- Display all 50+ weapons in grid
- Show weapon stats when clicked
- Equip different weapons and verify damage changes in combat

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://resources/weapon_resource.gd` - WeaponResource class definition
   - `res://resources/shield_resource.gd` - ShieldResource class definition
   - `res://autoloads/item_database.gd` - ItemDatabase singleton for loading and caching items
   - Complete implementations with full logic
   - Type hints, documentation, error handling

2. **Create all JSON data files** using the Write tool
   - `res://data/weapons.json` - 50+ weapon definitions with complete stats
   - `res://data/shields.json` - 15+ shield definitions with complete stats
   - Valid JSON format with all required fields

3. **Create HANDOFF-S07.md** documenting:
   - Minimal scene needs (just test scene for displaying weapons)
   - MCP agent tasks (use GDAI tools)
   - Autoload registration instructions
   - Testing steps for MCP agent

### Your Deliverables:
- `res://resources/weapon_resource.gd` - WeaponResource class
- `res://resources/shield_resource.gd` - ShieldResource class
- `res://autoloads/item_database.gd` - ItemDatabase singleton
- `res://data/weapons.json` - Complete weapons database (50+ items)
- `res://data/shields.json` - Complete shields database (15+ items)
- `HANDOFF-S07.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)
- Register autoload in project settings (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S07.md
2. Use GDAI tools to configure:
   - Register ItemDatabase as autoload in project settings
   - `create_scene` - Create test_weapons.tscn for displaying weapons
   - `add_node` - Build node hierarchies (GridContainer for weapon display)
   - Verify JSON files load correctly
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S07.md` with this structure:

```markdown
# HANDOFF: S07 - Weapons & Shields Database

## Files Created by Claude Code Web

### GDScript Files
- `res://resources/weapon_resource.gd` - WeaponResource class definition with damage, speed, range, attack patterns
- `res://resources/shield_resource.gd` - ShieldResource class definition with defense, block percentage, weight
- `res://autoloads/item_database.gd` - ItemDatabase singleton for loading and caching weapons/shields from JSON

### Data Files
- `res://data/weapons.json` - 50+ weapon definitions (swords, axes, spears, bows, staves, legendary)
- `res://data/shields.json` - 15+ shield definitions (small, medium, large)

## MCP Agent Tasks

### 1. Register ItemDatabase as Autoload

```bash
# Register ItemDatabase as autoload singleton
# In Godot Editor: Project → Project Settings → Autoload
# Add: res://autoloads/item_database.gd with name "ItemDatabase"
# This must be done manually in the Godot editor or via project.godot file
```

**Note:** Add this to `project.godot` file under `[autoload]` section:
```
ItemDatabase="*res://autoloads/item_database.gd"
```

### 2. Create Weapon Display Test Scene

```bash
# Create test scene for displaying weapons
create_scene res://tests/test_weapons.tscn
add_node res://tests/test_weapons.tscn Node2D TestWeapons root
add_node res://tests/test_weapons.tscn CanvasLayer UI TestWeapons
add_node res://tests/test_weapons.tscn Panel WeaponPanel UI
add_node res://tests/test_weapons.tscn VBoxContainer Layout WeaponPanel
add_node res://tests/test_weapons.tscn Label Title Layout

# Add weapon categories sections
add_node res://tests/test_weapons.tscn Label SwordsTitle Layout
add_node res://tests/test_weapons.tscn GridContainer SwordsGrid Layout

add_node res://tests/test_weapons.tscn Label AxesTitle Layout
add_node res://tests/test_weapons.tscn GridContainer AxesGrid Layout

add_node res://tests/test_weapons.tscn Label SpearsTitle Layout
add_node res://tests/test_weapons.tscn GridContainer SpearsGrid Layout

add_node res://tests/test_weapons.tscn Label BowsTitle Layout
add_node res://tests/test_weapons.tscn GridContainer BowsGrid Layout

add_node res://tests/test_weapons.tscn Label StavesTitle Layout
add_node res://tests/test_weapons.tscn GridContainer StavesGrid Layout

add_node res://tests/test_weapons.tscn Label LegendaryTitle Layout
add_node res://tests/test_weapons.tscn GridContainer LegendaryGrid Layout

# Add shields section
add_node res://tests/test_weapons.tscn Label ShieldsTitle Layout
add_node res://tests/test_weapons.tscn GridContainer ShieldsGrid Layout

# Add weapon detail panel
add_node res://tests/test_weapons.tscn Panel DetailPanel UI
add_node res://tests/test_weapons.tscn VBoxContainer DetailLayout DetailPanel
add_node res://tests/test_weapons.tscn Label DetailTitle DetailLayout
add_node res://tests/test_weapons.tscn Label DetailName DetailLayout
add_node res://tests/test_weapons.tscn Label DetailType DetailLayout
add_node res://tests/test_weapons.tscn Label DetailTier DetailLayout
add_node res://tests/test_weapons.tscn Label DetailDamage DetailLayout
add_node res://tests/test_weapons.tscn Label DetailSpeed DetailLayout
add_node res://tests/test_weapons.tscn Label DetailRange DetailLayout
add_node res://tests/test_weapons.tscn Label DetailPattern DetailLayout
add_node res://tests/test_weapons.tscn Label DetailEffects DetailLayout
add_node res://tests/test_weapons.tscn Label DetailValue DetailLayout

# Configure panel
update_property res://tests/test_weapons.tscn WeaponPanel custom_minimum_size "Vector2(600, 700)"
update_property res://tests/test_weapons.tscn WeaponPanel anchor_preset 0
update_property res://tests/test_weapons.tscn WeaponPanel position "Vector2(10, 10)"
update_property res://tests/test_weapons.tscn Title text "Weapons & Shields Database (50+ weapons, 15+ shields)"
update_property res://tests/test_weapons.tscn Title horizontal_alignment 1

# Configure category titles
update_property res://tests/test_weapons.tscn SwordsTitle text "=== SWORDS (10) ==="
update_property res://tests/test_weapons.tscn AxesTitle text "=== AXES (8) ==="
update_property res://tests/test_weapons.tscn SpearsTitle text "=== SPEARS (8) ==="
update_property res://tests/test_weapons.tscn BowsTitle text "=== BOWS (8) ==="
update_property res://tests/test_weapons.tscn StavesTitle text "=== STAVES (8) ==="
update_property res://tests/test_weapons.tscn LegendaryTitle text "=== LEGENDARY (8+) ==="
update_property res://tests/test_weapons.tscn ShieldsTitle text "=== SHIELDS (15+) ==="

# Configure grids
update_property res://tests/test_weapons.tscn SwordsGrid columns 5
update_property res://tests/test_weapons.tscn AxesGrid columns 4
update_property res://tests/test_weapons.tscn SpearsGrid columns 4
update_property res://tests/test_weapons.tscn BowsGrid columns 4
update_property res://tests/test_weapons.tscn StavesGrid columns 4
update_property res://tests/test_weapons.tscn LegendaryGrid columns 4
update_property res://tests/test_weapons.tscn ShieldsGrid columns 5

# Configure detail panel
update_property res://tests/test_weapons.tscn DetailPanel custom_minimum_size "Vector2(350, 400)"
update_property res://tests/test_weapons.tscn DetailPanel anchor_preset 1
update_property res://tests/test_weapons.tscn DetailPanel position "Vector2(-360, 10)"
update_property res://tests/test_weapons.tscn DetailTitle text "Weapon Details"
update_property res://tests/test_weapons.tscn DetailTitle horizontal_alignment 1
update_property res://tests/test_weapons.tscn DetailName text "Name: (Select a weapon)"
update_property res://tests/test_weapons.tscn DetailType text "Type: -"
update_property res://tests/test_weapons.tscn DetailTier text "Tier: -"
update_property res://tests/test_weapons.tscn DetailDamage text "Damage: -"
update_property res://tests/test_weapons.tscn DetailSpeed text "Speed: -"
update_property res://tests/test_weapons.tscn DetailRange text "Range: -"
update_property res://tests/test_weapons.tscn DetailPattern text "Attack Pattern: -"
update_property res://tests/test_weapons.tscn DetailEffects text "Special Effects: -"
update_property res://tests/test_weapons.tscn DetailValue text "Value: -"
```

### 3. Add Weapon Item Buttons (Optional - for interactive testing)

```bash
# Add sample weapon buttons to test clicking and viewing details
add_node res://tests/test_weapons.tscn Button WoodenSword SwordsGrid
add_node res://tests/test_weapons.tscn Button IronSword SwordsGrid
add_node res://tests/test_weapons.tscn Button SteelSword SwordsGrid

update_property res://tests/test_weapons.tscn WoodenSword text "Wooden Sword"
update_property res://tests/test_weapons.tscn IronSword text "Iron Sword"
update_property res://tests/test_weapons.tscn SteelSword text "Steel Sword"

# Note: In actual implementation, these buttons should be generated dynamically
# from ItemDatabase.get_all_weapons() in the test scene's script
```

## Testing Checklist

Use Godot MCP tools to test:

```bash
# Run test scene
play_scene res://tests/test_weapons.tscn

# Check for errors
get_godot_errors

# Verify ItemDatabase loads
# All weapons and shields should be accessible via ItemDatabase singleton
```

### Verify:
- [ ] ItemDatabase autoload registered and accessible globally (`ItemDatabase` works in any script)
- [ ] weapons.json loads without errors (check console for JSON parse errors)
- [ ] shields.json loads without errors
- [ ] ItemDatabase caches all WeaponResource instances at startup
- [ ] ItemDatabase caches all ShieldResource instances at startup
- [ ] get_weapon(id) returns correct WeaponResource (test with "wooden_sword", "iron_sword", etc.)
- [ ] get_shield(id) returns correct ShieldResource (test with shield IDs)
- [ ] get_all_weapons() returns Array with 50+ WeaponResource objects
- [ ] get_all_shields() returns Array with 15+ ShieldResource objects
- [ ] Weapon categories verified: 10 swords, 8 axes, 8 spears, 8 bows, 8 staves, 8+ legendary
- [ ] Shield categories verified: 5 small, 5 medium, 5 large (total 15+)
- [ ] All weapons have varied stats (damage: 5-50, speed: 0.5-2.0, range: 16-128)
- [ ] All shields have varied stats (defense: 5-30, block_percentage: 0.2-0.8, weight: 1.0-5.0)
- [ ] Special effects stored as Array[String] for future integration
- [ ] Tier system working (tiers 1-5)
- [ ] Icon paths defined (placeholder paths acceptable if icons not yet created)
- [ ] Value (gold cost) defined for all items

### Data Quality Verification:
- [ ] JSON is human-readable and properly formatted
- [ ] No duplicate IDs in weapons.json
- [ ] No duplicate IDs in shields.json
- [ ] All required fields present for each weapon (id, name, type, tier, damage, speed, range, attack_pattern, special_effects, icon_path, value)
- [ ] All required fields present for each shield (id, name, type, tier, defense, block_percentage, weight, special_properties, icon_path, value)
- [ ] Weapon types match expected values: sword, axe, spear, bow, staff
- [ ] Shield types match expected values: small, medium, large

### Integration Points:
- **S04 (Combat)**: Weapon damage can be applied to combat calculations
- **S05 (Inventory)**: Weapon/shield icons can be displayed in inventory UI
- Ready for **S08 (Equipment)** to equip weapons and shields
- Ready for **S10 (Special Moves)** for weapon-specific special attacks
- Ready for **S25 (Crafting)** for weapon enhancement and creation

### Extensibility Verification:
- [ ] Adding new weapon: Simply add JSON entry to weapons.json - no code changes needed
- [ ] Adding new shield: Simply add JSON entry to shields.json - no code changes needed
- [ ] Test by manually adding a custom weapon/shield to JSON and verifying it loads

## Completion

Update COORDINATION-DASHBOARD.md:
- Mark S07 as complete
- Release any locked resources
- Unblock S08 (Equipment), S10 (Special Moves), S25 (Crafting)
- Note: 50+ weapons and 15+ shields ready for use in equipment and combat systems
```

</handoff_requirements>

<data_driven_architecture>

To add new weapons:
```json
{
  "id": "new_legendary_sword",
  "name": "Excalibur",
  "type": "sword",
  "tier": 5,
  "damage": 50,
  "speed": 0.8,
  "range": 48,
  "attack_pattern": "divine_slash",
  "special_effects": ["light_damage", "holy_aura"],
  "icon_path": "res://assets/icons/weapons/excalibur.png",
  "value": 10000
}
```

Simply add to weapons.json - no code changes needed.

</data_driven_architecture>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S07.md, verify:

### Code Quality
- [ ] All .gd files created with complete implementations (no TODOs or placeholders)
- [ ] weapons.json and shields.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for classes and methods
- [ ] Error handling implemented where needed
- [ ] Integration patterns documented (signals, method calls)

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (resources/, autoloads/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schemas are complete and validated
- [ ] HANDOFF-S07.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] WeaponResource class with all required fields (id, name, type, tier, damage, speed, range, etc.)
- [ ] ShieldResource class with all required fields (id, name, type, tier, defense, block_percentage, etc.)
- [ ] ItemDatabase with get_weapon(), get_shield(), get_all_weapons(), get_all_shields() methods
- [ ] weapons.json contains 50+ weapon definitions across all weapon types
- [ ] shields.json contains 15+ shield definitions across all shield types
- [ ] All weapons have complete stats and varied balance
- [ ] JSON structure is consistent and extensible

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] ItemDatabase registered as autoload in project settings
- [ ] Test scene created using `create_scene`
- [ ] All nodes added using `add_node` in correct hierarchy
- [ ] Verify JSON files parse without errors

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S07")`
- [ ] Quality gates passed: `check_quality_gates("S07")`
- [ ] Checkpoint validated: `validate_checkpoint("S07")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] ItemDatabase autoload loads all 50+ weapons at startup
- [ ] ItemDatabase autoload loads all 15+ shields at startup
- [ ] WeaponResource and ShieldResource classes instantiate from JSON
- [ ] Weapons have varied stats (damage 5-50, speed 0.5-2.0, range 16-128)
- [ ] Special effects stored as string arrays for future integration
- [ ] Combat system (S04) can apply weapon damage correctly
- [ ] Inventory (S05) can display weapon/shield icons
- [ ] JSON is human-readable and easily tweakable
- [ ] get_weapon(id) returns correct WeaponResource
- [ ] Test scene displays all weapons without errors

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ WeaponResource and ShieldResource classes complete
- ✅ ItemDatabase singleton complete with loading logic
- ✅ weapons.json complete with 50+ weapon definitions
- ✅ shields.json complete with 15+ shield definitions
- ✅ HANDOFF-S07.md provides clear MCP agent instructions
- ✅ All data schemas validated and extensible

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ ItemDatabase registered as autoload and accessible globally
- ✅ All JSON files load without errors
- ✅ 50+ weapons and 15+ shields loaded and accessible
- ✅ Resource instantiation works correctly
- ✅ Test scene displays all items correctly
- ✅ All verification criteria pass
- ✅ System ready for dependent systems (S08, S10, S25)

</success_criteria>

<memory_checkpoint_format>
```
System S07 (Weapons Database) Complete

FILES CREATED:
- res://resources/weapon_resource.gd (WeaponResource class)
- res://resources/shield_resource.gd (ShieldResource class)
- res://autoloads/item_database.gd (ItemDatabase singleton)
- res://data/weapons.json (50+ weapon definitions)
- res://data/shields.json (15+ shield definitions)
- res://tests/test_weapons.tscn (Weapons display test scene)

WEAPON CATEGORIES:
- Swords: 10
- Axes: 8
- Spears: 8
- Bows: 8
- Staves: 8
- Unique/Legendary: 8+
Total: 50+ weapons

SHIELD CATEGORIES:
- Small: 5
- Medium: 5
- Large: 5
Total: 15+ shields

WEAPON STATS:
- damage, speed, range, attack_pattern, special_effects
- Tier system (1-5)
- Value (for shops)
- Icon path

SHIELD STATS:
- defense, block_percentage, weight, special_properties
- Tier system (1-5)
- Value (for shops)

METHODS:
- ItemDatabase.get_weapon(id) -> WeaponResource
- ItemDatabase.get_shield(id) -> ShieldResource
- ItemDatabase.get_all_weapons() -> Array[WeaponResource]
- ItemDatabase.get_all_shields() -> Array[ShieldResource]

INTEGRATION:
- Combat (S04) uses weapon damage in calculations
- Inventory (S05) displays weapon/shield icons
- Ready for S08 (Equipment) to equip weapons
- Ready for S10 (Special Moves) for weapon-specific attacks
- Ready for S25 (Crafting) for weapon enhancement

EXTENSIBILITY:
- Add new weapon: Simply add JSON entry to weapons.json
- Add new shield: Simply add JSON entry to shields.json
- No code changes needed for new items

STATUS: Ready for S08, S10, S25
```
</memory_checkpoint_format>
