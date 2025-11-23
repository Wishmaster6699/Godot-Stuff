<objective>
Implement Crafting System (S25) - combine base items with modifiers, weapon enchantment, armor customization (colors/stats), recipe unlock through discovery, material gathering from world/enemies.

DEPENDS ON: S08 (Equipment), S12 (Monsters for materials), S07 (Weapons)
WAVE 1 - Can run in parallel with S19, S24, S26
</objective>

<context>
Crafting allows players to customize equipment with stat bonuses, visual changes, and enchantments.

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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S25")`
- [ ] Quality gates: `check_quality_gates("S25")`
- [ ] Checkpoint validation: `validate_checkpoint("S25")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S25", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

## Implementation

### 1. Crafting System
Create `res://systems/crafting_system.gd`:
```gdscript
func craft(base_item: String, modifiers: Array) -> Dictionary:
  var result = duplicate_item(base_item)
  for modifier in modifiers:
    apply_modifier(result, modifier)
  return result
```

### 2. Crafting Recipes
```json
{
  "crafting_recipes": [
    {
      "id": "iron_sword_fire",
      "base_item": "iron_sword",
      "modifiers": ["fire_gem", "fire_essence"],
      "result": {
        "name": "Flaming Iron Sword",
        "stat_bonuses": { "damage": 5, "fire_damage": 10 },
        "visual": "fire_trail_particle"
      }
    },
    {
      "id": "leather_armor_blue",
      "base_item": "leather_armor",
      "modifiers": ["blue_dye"],
      "result": {
        "name": "Blue Leather Armor",
        "stat_bonuses": {},
        "visual": { "color": "#0000FF" }
      }
    }
  ]
}
```

### 3. Material Gathering
- Overworld: Ores, gems, plants
- Monster drops: Rare materials from S12
- Dungeons: Special crafting materials

### 4. Weapon Enchantment
Add elemental damage, stat boosts, special effects:
- Fire enchantment: +Fire damage, burn chance
- Ice enchantment: +Ice damage, slow effect
- Lightning: +Electric damage, stun chance

### 5. Armor Customization
- Color/dye system (visual only)
- Stat modifiers (defense, resistances)
- Set bonuses (matching armor pieces)

### 6. Recipe Discovery
- Find blueprints in world
- Learn from NPC craftsmen
- Experimentation (try combinations)

### 7. Test Scene
- Crafting UI with material selection
- Enchantment preview
- Color customization

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://systems/crafting_system.gd` - Complete crafting manager with recipe validation, modifier application, enchantment system
   - Weapon enchantment system (fire/ice/lightning)
   - Armor customization (colors, stats, set bonuses)
   - Recipe discovery system
   - Type hints, documentation, error handling

2. **Create all JSON data files** using the Write tool
   - `res://data/crafting_recipes.json` - Crafting recipes with base items and modifiers
   - Valid JSON format with all required fields

3. **Create HANDOFF-S25.md** documenting:
   - Scene structures needed (crafting UI test scene)
   - MCP agent tasks (use GDAI tools)
   - Property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- `res://systems/crafting_system.gd` - Complete crafting system implementation
- `res://data/crafting_recipes.json` - Crafting recipes data
- `HANDOFF-S25.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S25.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create test_crafting.tscn
   - `add_node` - Build node hierarchies for crafting UI
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set node properties
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S25.md` with this structure:

```markdown
# System S25 Handoff - Crafting System

**Created by:** Claude Code Web
**Date:** [timestamp]
**Status:** Ready for MCP Agent Configuration

---

## Files Created (Tier 1 Complete)

### GDScript Files
- `res://systems/crafting_system.gd` - Crafting manager with recipe validation, modifier application, enchantment system

### Data Files
- `res://data/crafting_recipes.json` - Crafting recipes with base items and modifiers

---

## Scene Configuration Needed (Tier 2 - MCP Agent Tasks)

### Scene 1: `res://tests/test_crafting.tscn`

**MCP Agent Commands:**
```gdscript
# Create test scene
create_scene("res://tests/test_crafting.tscn", "Node2D", "TestCrafting")

# Add UI elements
add_node("TestCrafting", "Label", "RecipeDisplay")
add_node("TestCrafting", "Label", "MaterialList")
add_node("TestCrafting", "Label", "ResultPreview")
add_node("TestCrafting", "Button", "EnchantFire")
add_node("TestCrafting", "Button", "EnchantIce")
add_node("TestCrafting", "Button", "CustomizeColor")
add_node("TestCrafting", "ColorPickerButton", "ColorPicker")

# Configure properties
update_property("TestCrafting/RecipeDisplay", "position", Vector2(10, 10))
update_property("TestCrafting/MaterialList", "position", Vector2(10, 40))
update_property("TestCrafting/ResultPreview", "position", Vector2(10, 100))
update_property("TestCrafting/EnchantFire", "position", Vector2(10, 150))
update_property("TestCrafting/EnchantFire", "text", "Enchant: Fire")
update_property("TestCrafting/EnchantIce", "position", Vector2(10, 190))
update_property("TestCrafting/EnchantIce", "text", "Enchant: Ice")
update_property("TestCrafting/CustomizeColor", "position", Vector2(10, 230))
update_property("TestCrafting/CustomizeColor", "text", "Customize Armor Color")
update_property("TestCrafting/ColorPicker", "position", Vector2(10, 270))
```

**Node Hierarchy:**
```
TestCrafting (Node2D)
├── RecipeDisplay (Label)
├── MaterialList (Label)
├── ResultPreview (Label)
├── EnchantFire (Button)
├── EnchantIce (Button)
├── CustomizeColor (Button)
└── ColorPicker (ColorPickerButton)
```

---

## Integration Points

### Signals Exposed:
- `item_crafted(item_id: String, modifiers: Array)` - Emitted when crafting completes
- `recipe_discovered(recipe_id: String)` - Emitted when new recipe discovered
- `enchantment_applied(item_id: String, enchantment: String)` - Emitted when item enchanted

### Public Methods:
- `craft(base_item: String, modifiers: Array) -> Dictionary` - Craft an item
- `apply_enchantment(item: Dictionary, enchantment: String) -> Dictionary` - Add enchantment
- `customize_armor(item: Dictionary, color: Color) -> Dictionary` - Change armor color
- `discover_recipe(recipe_id: String)` - Add recipe to known recipes

### Dependencies:
- Depends on: S08 (Equipment), S12 (Monsters for materials), S07 (Weapons)
- Depended on by: None (standalone system)

---

## Testing Checklist (MCP Agent)

After scene configuration, test with:

```gdscript
# Play test scene
play_scene("res://tests/test_crafting.tscn")

# Check for errors
get_godot_errors()

# Verify:
```
- [ ] Base items + modifiers = crafted item
- [ ] Weapon enchantments apply correctly (fire/ice/lightning)
- [ ] Armor color customization works
- [ ] Stat bonuses applied to equipment
- [ ] Material gathering from world/monsters works
- [ ] Recipe discovery system works
- [ ] Integration with S07 Weapons works
- [ ] Integration with S08 Equipment works
- [ ] Integration with S12 Monster drops works
- [ ] Crafting UI displays preview correctly
- [ ] crafting_recipes.json loads correctly

```gdscript
# Stop scene when done
stop_running_scene()
```

---

## Notes / Gotchas

- **Weapon Enchantments**: Fire (+fire damage, burn), Ice (+ice damage, slow), Lightning (+electric, stun)
- **Armor Customization**: Color (visual only), Stat modifiers (defense, resistances), Set bonuses
- **Recipe Discovery**: Blueprints (world), NPC craftsmen, Experimentation
- **Material Sources**: Overworld (ores, gems), Monster drops (rare materials), Dungeons

---

**Next Steps:** MCP agent should execute all commands above, then update COORDINATION-DASHBOARD.md to mark S25 complete.
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S25.md, verify:

### Code Quality
- [ ] crafting_system.gd created with complete implementation (no TODOs or placeholders)
- [ ] crafting_recipes.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented where needed
- [ ] Recipe validation logic implemented
- [ ] Modifier application system implemented
- [ ] Enchantment system implemented
- [ ] Armor customization implemented
- [ ] Integration with S07, S08, S12 documented

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (systems/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S25.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] All crafting data configurable from crafting_recipes.json
- [ ] No hardcoded recipes in crafting_system.gd
- [ ] Signal parameters documented
- [ ] Public methods have return type hints
- [ ] Configuration validation logic included

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] test_crafting.tscn created using `create_scene`
- [ ] All test scene nodes added using `add_node`
- [ ] Properties configured using `update_property`

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S25")`
- [ ] Quality gates passed: `check_quality_gates("S25")`
- [ ] Checkpoint validated: `validate_checkpoint("S25")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Base items + modifiers = crafted item correctly
- [ ] Weapon enchantments apply correctly (fire/ice/lightning)
- [ ] Armor color customization works
- [ ] Stat bonuses applied to equipment
- [ ] Material gathering from world/monsters works
- [ ] Recipe discovery system works (blueprints, NPCs, experimentation)
- [ ] Integration with S07 Weapons works
- [ ] Integration with S08 Equipment works
- [ ] Integration with S12 Monster drops works
- [ ] Crafting UI displays preview correctly
- [ ] crafting_recipes.json loads correctly

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ crafting_system.gd complete with recipe validation, modifier application, enchantment system
- ✅ crafting_recipes.json complete with all crafting recipes
- ✅ Weapon enchantment logic (fire/ice/lightning effects)
- ✅ Armor customization logic (colors, stats, set bonuses)
- ✅ Recipe discovery system implemented
- ✅ All code documented with type hints and comments
- ✅ HANDOFF-S25.md provides clear MCP agent instructions
- ✅ All crafting data configurable from JSON (no hardcoding)

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Test scene configured correctly in Godot editor
- ✅ Crafting UI functional with material selection
- ✅ Weapon enchantments add elemental damage and effects
- ✅ Armor customization changes colors and stats
- ✅ Set bonuses work when matching armor pieces equipped
- ✅ Recipe discovery through blueprints, NPCs, experimentation
- ✅ Material gathering from world and monsters
- ✅ Integrates with S07 Weapons for weapon crafting
- ✅ Integrates with S08 Equipment for armor crafting
- ✅ Integrates with S12 Monster Database for material drops
- ✅ Crafting preview shows final item stats before crafting

Crafting system allows deep equipment customization and player expression.

</success_criteria>

### Framework Quality Gates (REQUIRED)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Quality gates passed: `check_quality_gates("S25")`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S25")`
- [ ] Checkpoint validated: `validate_checkpoint("S25")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created: Document solutions in `knowledge-base/` if non-trivial

### System-Specific Verification

- [ ] Base items + modifiers = crafted item
- [ ] Weapon enchantments apply correctly
- [ ] Armor color customization works
- [ ] Stat bonuses applied to equipment
- [ ] Material gathering from world/monsters
- [ ] Recipe discovery system
- [ ] Integration with S07 Weapons
- [ ] Integration with S08 Equipment
- [ ] Integration with S12 Monster drops
- [ ] Crafting UI displays preview
</verification>

<memory_checkpoint_format>
```
System S25 (Crafting) Complete

FILES:
- res://systems/crafting_system.gd
- res://data/crafting_recipes.json
- res://ui/crafting_ui.tscn

CRAFTING FEATURES:
- Weapon enchantments (fire/ice/lightning)
- Armor customization (colors, stats)
- Set bonuses
- Material gathering

RECIPE DISCOVERY:
- Blueprints (world)
- NPC craftsmen
- Experimentation

STATUS: Crafting complete
```
</memory_checkpoint_format>
