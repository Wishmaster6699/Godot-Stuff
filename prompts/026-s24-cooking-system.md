<objective>
Implement Cooking System (S24) - 50+ ingredients from overworld/NPCs/monster drops, cooking methods (fire/oven/sandwich/shop recipes), town-specific recipes, 2-4 ingredient combinations, output (heals/stamina/buffs/effects), ingredient discovery, quality affects potency (Perfect/Good/Miss).

DEPENDS ON: S05 (Inventory), S12 (Monster Database for drops)
WAVE 1 - Can run in parallel with S19, S25, S26
</objective>

<context>
Cooking provides consumables for healing, buffs, and stamina restoration. Ingredients are gathered from the world and monsters. Recipes are discovered through experimentation or NPCs.

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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S24")`
- [ ] Quality gates: `check_quality_gates("S24")`
- [ ] Checkpoint validation: `validate_checkpoint("S24")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S24", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

## Implementation

### 1. Cooking System
Create `res://systems/cooking_system.gd`:
```gdscript
var known_recipes = []
var ingredients_discovered = []

func cook(recipe_id: String, ingredients: Array):
  if validate_recipe(recipe_id, ingredients):
    var quality = determine_quality()  # Based on rhythm timing
    var result = create_dish(recipe_id, quality)
    return result
```

### 2. Ingredients Database
Create `res://data/ingredients.json` (50+ ingredients):
```json
{
  "ingredients": [
    {
      "id": "mushroom",
      "name": "Forest Mushroom",
      "type": "vegetable",
      "source": "overworld_forest",
      "rarity": "common"
    },
    {
      "id": "dragon_scale",
      "name": "Dragon Scale",
      "type": "rare_material",
      "source": "monster_drop",
      "monster_id": "095_dragon",
      "rarity": "legendary"
    }
  ]
}
```

### 3. Recipe System
Create `res://data/recipes.json`:
```json
{
  "recipes": [
    {
      "id": "mushroom_soup",
      "name": "Mushroom Soup",
      "ingredients": ["mushroom", "water", "salt"],
      "cooking_method": "fire",
      "output": {
        "item_id": "mushroom_soup_item",
        "effects": { "heal_hp": 50, "buff_defense": 5 },
        "duration_s": 60
      },
      "town_specific": "forest_town",
      "discovery_method": "npc_elder"
    }
  ]
}
```

### 4. Cooking Methods
- **Fire**: Campfire cooking (grilled, roasted)
- **Oven**: Town ovens (baked, slow-cooked)
- **Sandwich**: Quick assembly (no cooking)
- **Shop Recipes**: Learn from NPC chefs

### 5. Quality System
Rhythm timing during cooking affects potency:
- Perfect (on beat): 150% effectiveness
- Good: 100% effectiveness
- Miss: 50% effectiveness

### 6. Ingredient Gathering
- Overworld: Gather from bushes, trees, rocks
- Monster Drops: Rare ingredients from S12 loot tables
- NPC Gifts: Relationship rewards from S22

### 7. Town-Specific Recipes
Each town has unique recipes using local ingredients

### 8. Experimentation
Try ingredient combinations to discover new recipes

### 9. Test Scene
- Cooking UI with ingredient selection
- Quality timing mini-game
- Recipe discovery system

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://systems/cooking_system.gd` - Complete cooking manager with recipe validation, quality system, ingredient tracking
   - Cooking methods (fire, oven, sandwich, shop recipes)
   - Quality timing system (Perfect/Good/Miss affects potency)
   - Type hints, documentation, error handling

2. **Create all JSON data files** using the Write tool
   - `res://data/ingredients.json` - 50+ ingredients with sources and rarity
   - `res://data/recipes.json` - 20+ recipes with cooking methods and effects
   - Valid JSON format with all required fields

3. **Create HANDOFF-S24.md** documenting:
   - Scene structures needed (cooking UI test scene)
   - MCP agent tasks (use GDAI tools)
   - Property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- `res://systems/cooking_system.gd` - Complete cooking system implementation
- `res://data/ingredients.json` - 50+ ingredients data
- `res://data/recipes.json` - 20+ recipes data
- `HANDOFF-S24.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S24.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create test_cooking.tscn
   - `add_node` - Build node hierarchies for cooking UI
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set node properties
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S24.md` with this structure:

```markdown
# System S24 Handoff - Cooking System

**Created by:** Claude Code Web
**Date:** [timestamp]
**Status:** Ready for MCP Agent Configuration

---

## Files Created (Tier 1 Complete)

### GDScript Files
- `res://systems/cooking_system.gd` - Cooking manager with recipe validation, quality system, ingredient tracking

### Data Files
- `res://data/ingredients.json` - 50+ ingredients with sources and rarity
- `res://data/recipes.json` - 20+ recipes with cooking methods and effects

---

## Scene Configuration Needed (Tier 2 - MCP Agent Tasks)

### Scene 1: `res://tests/test_cooking.tscn`

**MCP Agent Commands:**
```gdscript
# Create test scene
create_scene("res://tests/test_cooking.tscn", "Node2D", "TestCooking")

# Add UI elements
add_node("TestCooking", "Label", "RecipeDisplay")
add_node("TestCooking", "Label", "IngredientList")
add_node("TestCooking", "Label", "QualityDisplay")
add_node("TestCooking", "Button", "CookFire")
add_node("TestCooking", "Button", "CookOven")
add_node("TestCooking", "Button", "MakeSandwich")
add_node("TestCooking", "ProgressBar", "TimingBar")

# Configure properties
update_property("TestCooking/RecipeDisplay", "position", Vector2(10, 10))
update_property("TestCooking/IngredientList", "position", Vector2(10, 40))
update_property("TestCooking/QualityDisplay", "position", Vector2(10, 100))
update_property("TestCooking/CookFire", "position", Vector2(10, 150))
update_property("TestCooking/CookFire", "text", "Cook Over Fire")
update_property("TestCooking/CookOven", "position", Vector2(10, 190))
update_property("TestCooking/CookOven", "text", "Cook in Oven")
update_property("TestCooking/MakeSandwich", "position", Vector2(10, 230))
update_property("TestCooking/MakeSandwich", "text", "Make Sandwich")
update_property("TestCooking/TimingBar", "position", Vector2(10, 280))
update_property("TestCooking/TimingBar", "size", Vector2(300, 20))
```

**Node Hierarchy:**
```
TestCooking (Node2D)
├── RecipeDisplay (Label)
├── IngredientList (Label)
├── QualityDisplay (Label)
├── CookFire (Button)
├── CookOven (Button)
├── MakeSandwich (Button)
└── TimingBar (ProgressBar)
```

---

## Integration Points

### Signals Exposed:
- `dish_cooked(dish_id: String, quality: String)` - Emitted when cooking completes
- `recipe_discovered(recipe_id: String)` - Emitted when new recipe discovered
- `ingredient_used(ingredient_id: String, amount: int)` - Emitted when ingredient consumed

### Public Methods:
- `cook(recipe_id: String, ingredients: Array) -> Dictionary` - Cook a recipe
- `determine_quality(timing_ms: float) -> String` - Calculate quality (Perfect/Good/Miss)
- `discover_recipe(recipe_id: String)` - Add recipe to known recipes
- `has_ingredients(recipe_id: String) -> bool` - Check if player has ingredients

### Dependencies:
- Depends on: S05 (Inventory), S12 (Monster Database for drops)
- Depended on by: None (standalone system)

---

## Testing Checklist (MCP Agent)

After scene configuration, test with:

```gdscript
# Play test scene
play_scene("res://tests/test_cooking.tscn")

# Check for errors
get_godot_errors()

# Verify:
```
- [ ] 50+ ingredients defined in ingredients.json
- [ ] 20+ recipes defined in recipes.json
- [ ] Cooking methods work (fire/oven/sandwich)
- [ ] Quality affects dish potency (Perfect/Good/Miss)
- [ ] Ingredient gathering from overworld works
- [ ] Monster drops provide rare ingredients (S12 integration)
- [ ] Recipe discovery through experimentation works
- [ ] Town-specific recipes available
- [ ] Integration with Inventory (S05) works
- [ ] Consumables provide buffs/heals
- [ ] Data files load correctly

```gdscript
# Stop scene when done
stop_running_scene()
```

---

## Notes / Gotchas

- **Quality System**: Perfect (150% potency), Good (100%), Miss (50%)
- **Ingredient Count**: Minimum 50 ingredients required
- **Recipe Count**: Minimum 20 recipes required
- **Cooking Methods**: Fire (campfire), Oven (town buildings), Sandwich (no cooking), Shop (NPC chefs)
- **Town-Specific**: Each town has unique recipes using local ingredients

---

**Next Steps:** MCP agent should execute all commands above, then update COORDINATION-DASHBOARD.md to mark S24 complete.
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S24.md, verify:

### Code Quality
- [ ] cooking_system.gd created with complete implementation (no TODOs or placeholders)
- [ ] ingredients.json created with 50+ ingredients, valid JSON (no syntax errors)
- [ ] recipes.json created with 20+ recipes, valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented where needed
- [ ] Recipe validation logic implemented
- [ ] Quality system implemented (Perfect/Good/Miss)
- [ ] Ingredient tracking implemented
- [ ] Integration with S05 and S12 documented

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (systems/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S24.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] All cooking data configurable from JSON files
- [ ] No hardcoded recipes or ingredients in cooking_system.gd
- [ ] Signal parameters documented
- [ ] Public methods have return type hints
- [ ] Configuration validation logic included
- [ ] Minimum 50 ingredients in ingredients.json
- [ ] Minimum 20 recipes in recipes.json

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] test_cooking.tscn created using `create_scene`
- [ ] All test scene nodes added using `add_node`
- [ ] Properties configured using `update_property`

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S24")`
- [ ] Quality gates passed: `check_quality_gates("S24")`
- [ ] Checkpoint validated: `validate_checkpoint("S24")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] 50+ ingredients load from ingredients.json
- [ ] 20+ recipes load from recipes.json
- [ ] Cooking methods work (fire/oven/sandwich)
- [ ] Quality affects dish potency (Perfect 150%, Good 100%, Miss 50%)
- [ ] Ingredient gathering from overworld works
- [ ] Monster drops provide rare ingredients (S12 integration)
- [ ] Recipe discovery through experimentation works
- [ ] Town-specific recipes available
- [ ] Integration with Inventory (S05) works
- [ ] Consumables provide buffs/heals correctly

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ cooking_system.gd complete with recipe validation, quality system, ingredient tracking
- ✅ ingredients.json complete with 50+ ingredients
- ✅ recipes.json complete with 20+ recipes
- ✅ Quality system logic (Perfect/Good/Miss affects potency)
- ✅ All code documented with type hints and comments
- ✅ HANDOFF-S24.md provides clear MCP agent instructions
- ✅ All cooking data configurable from JSON (no hardcoding)

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Test scene configured correctly in Godot editor
- ✅ Cooking UI functional with ingredient selection
- ✅ All cooking methods work (fire, oven, sandwich, shop recipes)
- ✅ Quality timing system affects dish potency correctly
- ✅ Ingredient gathering from overworld and monsters
- ✅ Recipe discovery through experimentation
- ✅ Town-specific recipes available
- ✅ Integrates with S05 Inventory for ingredient storage
- ✅ Integrates with S12 Monster Database for rare drops
- ✅ Consumables provide healing, stamina, buffs as configured

Cooking system provides consumables that enhance gameplay across all systems.

</success_criteria>

### Framework Quality Gates (REQUIRED)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Quality gates passed: `check_quality_gates("S24")`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S24")`
- [ ] Checkpoint validated: `validate_checkpoint("S24")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created: Document solutions in `knowledge-base/` if non-trivial

### System-Specific Verification

- [ ] 50+ ingredients defined in JSON
- [ ] 20+ recipes defined
- [ ] Cooking methods work (fire/oven/sandwich)
- [ ] Quality affects dish potency (Perfect/Good/Miss)
- [ ] Ingredient gathering from overworld
- [ ] Monster drops provide rare ingredients (S12)
- [ ] Recipe discovery through experimentation
- [ ] Town-specific recipes
- [ ] Integration with Inventory (S05)
- [ ] Consumables provide buffs/heals
</verification>

<memory_checkpoint_format>
```
System S24 (Cooking) Complete

FILES:
- res://systems/cooking_system.gd
- res://data/ingredients.json (50+ ingredients)
- res://data/recipes.json (20+ recipes)
- res://ui/cooking_ui.tscn

INGREDIENTS: 50+ (common to legendary)

COOKING METHODS:
- Fire (campfire)
- Oven (town buildings)
- Sandwich (no cooking)
- Shop recipes (NPC chefs)

QUALITY SYSTEM:
- Perfect: 150% potency
- Good: 100% potency
- Miss: 50% potency

TOWN-SPECIFIC RECIPES: Each town has unique dishes

STATUS: Cooking complete
```
</memory_checkpoint_format>
