# Research: S25 - Crafting System
**Agent:** Claude Code Web
**Date:** 2025-11-18
**Duration:** 45 minutes

## Godot 4.5 Documentation

### Crafting System Architecture
- **Wayline.io Tutorial (July 2025)**: Comprehensive crafting system tutorial
  - Key insight: Resource gathering, collision detection, inventory management
  - Pattern: Use separate CraftingManager to handle recipe validation
  - URL: https://www.wayline.io/blog/godot-crafting-system-tutorial

- **Toxigon Inventory Tutorial (October 2025 - Godot 4.5)**:
  - Key insight: Use tags for items (["weapon", "sword", "metal"]) for crafting filters
  - Pattern: Tag-based system allows flexible recipe matching
  - URL: https://toxigon.com/creating-a-simple-inventory-system-in-godot

### Stat/Modifier System
- **Minoqi Modular Stat System**:
  - Pattern: Abstract Modifier class with enter/exit/update methods
  - Key insight: Stat modifiers with different calculation types and durations
  - Application: Used for enchantment system - temp/permanent stat changes
  - URL: https://minoqi.vercel.app/posts/godot-4-tutorials/stat-system-godot-4-tutorial/

### Design Patterns
- **GDQuest Mediator Pattern**:
  - Pattern: Mediator pattern for system communication
  - Key insight: Crafting system needs to communicate with inventory without tight coupling
  - Application: CraftingSystem signals to EquipmentManager and Inventory
  - URL: https://www.gdquest.com/tutorial/godot/design-patterns/mediator/

## Existing Projects

### spaceyjase/godot-crafting (GitHub)
- Pattern: SlotPanel for inventory and crafting tables with drag-and-drop
- Key insight: Items generated when they match known 'Recipe'
- Architecture: Recipe-based crafting with material validation
- URL: https://github.com/spaceyjase/godot-crafting

### GLoot Plugin
- Universal inventory system for Godot
- Pattern: Item as separate resources
- Key insight: Modular design separates logic from UI
- Compatible: Godot 4.x, multiplayer-ready
- URL: https://github.com/peter-kish/gloot

## Code Patterns

### Recipe Validation Pattern
```gdscript
func _find_recipe(base_item: String, modifiers: Array) -> Dictionary:
    for recipe_id in recipe_database.keys():
        var recipe = recipe_database[recipe_id]
        if recipe.get("base_item", "") != base_item:
            continue
        if _modifiers_match(modifiers, recipe.get("modifiers", [])):
            return recipe
    return {}
```

### Enchantment System Pattern
```gdscript
# Dictionary-driven enchantment effects
var enchantment_effects: Dictionary = {
    "fire": {
        "damage_type": "fire",
        "damage_bonus": 10,
        "status_effect": "burn",
        "status_chance": 0.25
    }
}

# Apply enchantment by merging effect data
func apply_enchantment(item: Dictionary, enchantment: String) -> Dictionary:
    var effect = enchantment_effects[enchantment]
    # Merge effect into item stats
```

### Set Bonus Pattern
```gdscript
# Check equipped armor pieces and apply set bonuses
func get_armor_set_bonus(equipped_armor: Array[String]) -> Dictionary:
    var total_bonuses: Dictionary = {}
    for set_name in armor_sets.keys():
        var equipped_count = 0
        # Count matching pieces
        # Apply 2-piece and 3-piece bonuses based on count
    return total_bonuses
```

## Key Decisions

### 1. Recipe Storage Format
- **Decision**: Store recipes as JSON with base_item + modifiers array
- **Why**: Flexible, data-driven, easy to add new recipes without code changes
- **Pattern**: `{"base_item": "iron_sword", "modifiers": ["fire_gem", "fire_essence"]}`

### 2. Discovery System
- **Decision**: Three discovery methods - blueprint, NPC, experimentation
- **Why**: Adds gameplay variety, rewards exploration and player interaction
- **Implementation**: `discovery_method` field in recipe + `try_experimental_craft()` method

### 3. Enchantment Integration
- **Decision**: Enchantments as separate method from crafting
- **Why**: Allows enchanting existing items, not just crafting new ones
- **Pattern**: `apply_enchantment(item, "fire")` returns modified item

### 4. Set Bonus System
- **Decision**: Calculate set bonuses dynamically based on equipped items
- **Why**: More flexible than hardcoding, supports future expansion
- **Pattern**: Check equipped items against set definitions, apply cumulative bonuses

### 5. Material Database
- **Decision**: Separate material definitions from recipes
- **Why**: Allows reuse of materials across recipes, central material info
- **Future**: Load from materials.json (currently hardcoded for Tier 1)

## Integration Points

### S08 Equipment System
- **Integration**: EquipmentManager.equip_item() with crafted items
- **Signal**: Listen to `item_crafted` signal to add item to inventory
- **Pattern**: Crafted items return Dictionary compatible with Equipment system

### S12 Monster Database
- **Integration**: Monster drops provide crafting materials
- **Future**: monster_db.get_monster_drops() → crafting materials
- **Pattern**: Material IDs match monster drop IDs

### S07 Weapons Database
- **Integration**: WeaponResource.duplicate_weapon() for crafting modified weapons
- **Pattern**: Base weapons from weapons database, craft() modifies copy
- **Future**: Direct integration with weapon database for base items

### S05 Inventory System (Future)
- **Integration**: Check inventory for materials, consume on craft
- **Methods needed**: `player_inventory.has_item()`, `remove_item()`
- **Currently**: Placeholder methods return true (for Tier 1)

## Gotchas for Tier 2

### 1. JSON Loading
- **Watch**: FileAccess.open() can fail silently if path wrong
- **Solution**: Always check if file is null before reading
- **Path**: Use `res://data/` for all data files

### 2. Dictionary Type Handling
- **Watch**: JSON loads as Variant, need explicit casting
- **Solution**: Cast arrays with `as Array`, dictionaries with `as Dictionary`
- **Example**: `var recipe_list = data["crafting_recipes"] as Array`

### 3. Modifier Matching
- **Watch**: Modifier order shouldn't matter for recipe matching
- **Solution**: Sort both arrays before comparing
- **Pattern**: `_modifiers_match()` helper method handles this

### 4. Signal Parameters
- **Watch**: Signals must have typed parameters in Godot 4.5
- **Example**: `signal item_crafted(item_id: String, modifiers: Array, result: Dictionary)`

### 5. Color Customization
- **Watch**: Color type in JSON requires special handling
- **Solution**: Store as hex string "#RRGGBB", convert to Color in code
- **Pattern**: `customization["color"]` expects Color object, not string

## GDScript 4.5 Specifics

### String Operations
- **CRITICAL**: Use `.repeat()` NOT `*` operator
- **Example**: `"=".repeat(60)` NOT `"=" * 60`

### Type Hints
- **Required**: All function parameters and returns
- **Example**: `func craft(base_item: String, modifiers: Array) -> Dictionary:`
- **Arrays**: Use typed arrays `Array[String]` where possible

### Preload Pattern
- **Pattern**: Use preload() for cross-file references
- **Not needed**: This system is autoload, no cross-loading needed
- **Future**: If integrating weapon resources, use preload

### Signal Syntax
- **Godot 4.5**: Use `.emit()` not manual emission
- **Example**: `item_crafted.emit(base_item, modifiers, result)`

## Reusable Patterns

### 1. Recipe Discovery System
- **Reusable for**: Quest system, skill unlocks, achievement unlocks
- **Pattern**: Known items array + discovery methods + signals
- **Code**: See `discover_recipe()` and `try_experimental_craft()`

### 2. Set Bonus Calculation
- **Reusable for**: Skill trees, team bonuses, combo systems
- **Pattern**: Count matching elements, apply tier-based bonuses
- **Code**: See `get_armor_set_bonus()`

### 3. Modifier Application
- **Reusable for**: Buff/debuff system, status effects, temporary powerups
- **Pattern**: Dictionary of effects + apply method
- **Code**: See `apply_enchantment()` and enchantment_effects dictionary

## References

**Crafting Tutorials:**
- Wayline Crafting Tutorial: https://www.wayline.io/blog/godot-crafting-system-tutorial
- Zenva Crafting Course: https://academy.zenva.com/product/godot-crafting-system/
- Toxigon Inventory (4.5): https://toxigon.com/creating-a-simple-inventory-system-in-godot

**Stat/Modifier Systems:**
- Minoqi Stat System: https://minoqi.vercel.app/posts/godot-4-tutorials/stat-system-godot-4-tutorial/
- GLoot Plugin: https://github.com/peter-kish/gloot
- Expresso Bits Inventory: https://github.com/expressobits/inventory-system

**Design Patterns:**
- GDQuest Mediator Pattern: https://www.gdquest.com/tutorial/godot/design-patterns/mediator/
- GDQuest Design Patterns: https://www.gdquest.com/tutorial/godot/design-patterns/intro-to-design-patterns/
- Godot 4 Recipes: https://kidscancode.org/godot_recipes/4.x/

**Code Examples:**
- spaceyjase Crafting Demo: https://github.com/spaceyjase/godot-crafting
- Godot 4 Dev Cookbook: https://github.com/PacktPublishing/Godot-4-Game-Development-Cookbook

## Performance Considerations

### Recipe Lookup
- **Current**: Linear search through recipe_database
- **Optimization**: If >100 recipes, consider hash-based lookup
- **Acceptable**: Current implementation fine for ~50 recipes

### Set Bonus Calculation
- **Current**: Recalculated on demand
- **Optimization**: Cache results, invalidate on equipment change
- **Future**: Add to EquipmentManager._recalculate_stats()

### Material Validation
- **Current**: Placeholder (returns true)
- **Integration**: Will depend on S05 Inventory performance
- **Watch**: If inventory has 1000+ items, optimize has_item() calls

## Testing Strategy for Tier 2

### Unit Tests
1. Recipe matching (base + modifiers)
2. Enchantment application (stat bonuses)
3. Set bonus calculation (2-piece, 3-piece)
4. Recipe discovery (all three methods)

### Integration Tests
1. Craft item → appears in inventory
2. Enchant weapon → stats increase correctly
3. Equip armor set → bonuses apply
4. Discover recipe → can now craft

### Visual Tests
1. Enchantment particles display correctly
2. Armor color customization shows in-game
3. Crafting UI updates with available recipes

## Success Metrics

- ✅ All recipes load from JSON without errors
- ✅ Crafting produces correct items with bonuses
- ✅ Enchantments add elemental damage + effects
- ✅ Set bonuses calculate correctly for 2-piece and 3-piece
- ✅ Recipe discovery works for all three methods
- ✅ Integration with S08 Equipment successful
- ✅ No performance issues with recipe lookup

## Time Estimate for Tier 2

- Scene creation: 30 minutes
- UI configuration: 45 minutes
- Testing and debugging: 1 hour
- Integration verification: 30 minutes
- **Total: ~2.5 hours**
