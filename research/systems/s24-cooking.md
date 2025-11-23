# Research: S24 - Cooking System
**Agent:** Claude Code Web
**Date:** 2025-11-18
**Duration:** 30 minutes

## Godot 4.5 Crafting System Patterns

### Key Resources Found

#### 1. expressobits/inventory-system
- **URL:** https://github.com/expressobits/inventory-system
- **Key Insight:** Modular craft system separated from UI, compatible with multiplayer
- **Pattern:** Using items as separate resources (Godot 4 best practice)

#### 2. don-tnowe/godot-wyvernbox-inventory
- **URL:** https://github.com/don-tnowe/godot-wyvernbox-inventory
- **Key Insight:** Defines recipes through `ItemConversion` resource
- **Pattern:** Can provide pre-determined results, randomized counts, or fresh items from ItemGenerator

#### 3. spaceyjase/godot-crafting
- **URL:** https://github.com/spaceyjase/godot-crafting
- **Key Insight:** Items and Recipes both implemented as resources
- **Pattern:** Drag-and-drop matching against known recipes

#### 4. Toxigon Inventory Tutorial (Oct 2025)
- **URL:** https://toxigon.com/creating-a-simple-inventory-system-in-godot
- **Key Insight:** Dictionaries work well for crafting-heavy games
- **Pattern:** Use tags for crafting filters

## Chosen Architecture

### Core Design Decisions

1. **Recipe Storage:** JSON-based data files (not Resource files)
   - Why: Easier to edit and expand 50+ ingredients
   - Better for non-programmer content creators
   - Can be loaded dynamically

2. **Cooking System Structure:**
   - CookingSystem autoload singleton
   - Manages known recipes, discovered ingredients
   - Handles quality calculation (rhythm-based)
   - Validates recipe requirements

3. **Quality System Integration:**
   - Perfect: 150% potency (rhythm timing on beat)
   - Good: 100% potency
   - Miss: 50% potency
   - Integrates with S01 Conductor for timing

4. **Integration Points:**
   - S05 Inventory: Check/consume ingredients, add cooked items
   - S12 Monster Database: Rare ingredient drops
   - S01 Conductor: Timing for quality calculation

## GDScript 4.5 Patterns to Use

### Type Hints (Required)
```gdscript
var known_recipes: Array[String] = []
var ingredients_discovered: Array[String] = []

func cook(recipe_id: String, ingredients: Array[String], timing_ms: float) -> Dictionary:
    pass
```

### Signal Pattern
```gdscript
signal dish_cooked(dish_id: String, quality: String)
signal recipe_discovered(recipe_id: String)
signal ingredient_used(ingredient_id: String, amount: int)
```

### JSON Loading (Godot 4.5)
```gdscript
func load_ingredients() -> void:
    var file = FileAccess.open("res://data/ingredients.json", FileAccess.READ)
    var json = JSON.new()
    var parse_result = json.parse(file.get_as_text())
    if parse_result == OK:
        var data = json.data
```

## Gotchas for Tier 2

1. **String Repetition:** Use `.repeat()` not `*` operator
   - ❌ `"═" * 60`
   - ✅ `"═".repeat(60)`

2. **Class Names:** Add `class_name` to avoid autoload conflicts
   - Use `CookingSystemImpl` if needed

3. **FileAccess:** Use `FileAccess.open()` not old `File.new()`

4. **Timing Integration:** Conductor.beat signal for timing windows

## Data Schema Decisions

### Ingredients Schema
```json
{
  "id": "unique_id",
  "name": "Display Name",
  "type": "vegetable|meat|spice|rare_material",
  "source": "overworld_forest|monster_drop|npc_gift|shop",
  "monster_id": "095_dragon" (if source=monster_drop),
  "rarity": "common|uncommon|rare|legendary"
}
```

### Recipes Schema
```json
{
  "id": "recipe_id",
  "name": "Dish Name",
  "ingredients": ["ingredient_id1", "ingredient_id2"],
  "cooking_method": "fire|oven|sandwich|shop",
  "output": {
    "item_id": "result_item_id",
    "effects": {
      "heal_hp": 50,
      "heal_stamina": 30,
      "buff_attack": 10,
      "buff_defense": 5
    },
    "duration_s": 60
  },
  "town_specific": "forest_town|desert_town|mountain_town|null",
  "discovery_method": "experimentation|npc_elder|shop"
}
```

## Performance Considerations

- Cache loaded recipes/ingredients in memory
- Use dictionaries for O(1) lookups
- Lazy load data on first access
- No per-frame processing needed

## Testing Strategy for Tier 2

1. Load all ingredients (verify 50+ loaded)
2. Load all recipes (verify 20+ loaded)
3. Test cooking with valid ingredients
4. Test quality calculation (Perfect/Good/Miss)
5. Test town-specific recipe filtering
6. Test ingredient discovery system
7. Integration test with S05 Inventory
8. Integration test with S12 Monster drops

## References

- Godot 4.5 FileAccess docs: https://docs.godotengine.org/en/stable/classes/class_fileaccess.html
- Godot 4.5 JSON parsing: https://docs.godotengine.org/en/stable/classes/class_json.html
- GDScript 4.5 signals: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#signals
