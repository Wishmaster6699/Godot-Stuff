# Research: S08 - Equipment System
**Agent:** Claude Code Web
**Date:** 2025-11-18
**Duration:** 45 minutes
**System:** Equipment System with 5 slots, stat bonuses, and inventory integration

---

## Godot 4.5 Documentation

### Equipment System Patterns
- **Modular Stat System Tutorial**: https://medium.com/@minoqi/modular-stat-attribute-system-tutorial-for-godot-4-0bac1c5062ce
  - Key insight: Use Resource-based stats with modifier arrays
  - Pattern: Store base value, adjusted value, and list of modifiers
  - Implementation: Allows both additive and multiplicative bonuses

- **Tactics RPG Stats Tutorial**: https://theliquidfire.com/2024/10/10/godot-tactics-rpg-09-stats/
  - Key insight: Modifier sort order is critical for applying bonuses
  - Pattern: Apply percentage changes before/after additive bonuses
  - Implementation: Use arrays to store multiple modifiers with priority

- **Enhanced Stat Addon**: https://github.com/Zennyth/EnhancedStat
  - Godot 4.1+ addon for managing stats (Health, Mana, Speed, Attack)
  - Flexible modification through addition, multiplication, or custom methods
  - Could be integrated but chose custom solution for simplicity

### Drag-Drop UI Systems
- **Godot 4.x Drag-Drop Tutorial**: https://dev.to/pdeveloper/godot-4x-drag-and-drop-5g13
  - **Critical**: Use built-in Control node functions:
    - `_get_drag_data(at_position)` - Returns data being dragged
    - `_can_drop_data(at_position, data)` - Validates if drop is allowed
    - `_drop_data(at_position, data)` - Handles the drop action
  - Pattern: Create preview node during drag
  - Implementation: Each slot overrides these 3 functions

- **Grid Inventory System**: https://medium.com/@thrivevolt/making-a-grid-inventory-system-with-godot-727efedb71f7
  - Comprehensive guide for grid-based inventory
  - Includes drag preview implementation
  - Useful for future inventory-equipment integration

- **Drag-Drop Inventory Asset**: https://github.com/jlucaso1/drag-drop-inventory
  - Godot 4 inventory with built-in drag-drop
  - Features: Item swapping, specific equip slots, type validation
  - Asset Library: https://godotengine.org/asset-library/asset/2026

### Available Inventory Systems
- **Godot Dynamic Inventory**: https://github.com/alfredbaudisch/GodotDynamicInventorySystem
  - Updated for Godot 4.2+
  - Features: Dynamic UI, infinite scrolling, item categories, equipment slots
  - Uses custom Resources with different attributes
  - Database separated by categories

- **Wyvernbox**: https://godotengine.org/asset-library/asset/1919
  - Action RPG focused inventory system
  - Godot 4 compatible
  - Items defined through ItemType resources

- **GLoot Plugin**: Used by S05 (Inventory)
  - Already integrated in this project
  - Provides Inventory and GridConstraint classes
  - Equipment system designed to work alongside GLoot

---

## Existing Godot 4.5 Projects

### Reference Implementations
1. **3D RPG Clothing System**: https://forum.godotengine.org/t/3d-rpg-clothing-and-inventory-system-using-godot-4-and-blender/114842
   - Godot 4 tutorial for equipment visual representation
   - Adaptable to 2D sprite systems
   - Visual equipment layers on character model

2. **Forum Discussion - Stat Increases**: https://forum.godotengine.org/t/how-to-increase-stats-when-using-equipment/59285
   - Community patterns for equipment stat bonuses
   - Common approach: Recalculate on equip/unequip events
   - Use signals to notify combat/UI systems

---

## Code Patterns Discovered

### 1. Equipment Slot Validation

```gdscript
func _can_equip_in_slot(item_data: Dictionary, slot: String) -> bool:
    # Get item's required slot from data
    var item_slot = item_data.get("slot", "")

    # Special case for accessories (can have multiple)
    if slot == "accessories":
        return item_slot in ["accessory", "accessories"]

    # Exact match for other slots
    return item_slot == slot
```

**Why this works:**
- Items define their own slot type in data
- Prevents equipping helmet in boots slot
- Accessories handled separately (array vs single item)

### 2. Stat Bonus Calculation

```gdscript
func _recalculate_stats() -> void:
    # Reset all bonuses to zero
    current_stat_bonuses = { "defense": 0, "attack": 0, ... }

    # Add bonuses from each slot
    for slot in ["weapon", "helmet", "torso", "boots"]:
        var item = equipped_items[slot]
        if item != null:
            _add_item_bonuses(item)

    # Add bonuses from accessories (array)
    for accessory in equipped_items["accessories"]:
        _add_item_bonuses(accessory)

    # Emit signal to update UI/combat systems
    stats_changed.emit(current_stat_bonuses)
```

**Why this works:**
- Simple additive system (can extend to multiplicative later)
- Recalculates on every equip/unequip
- Single source of truth for current bonuses
- Signal pattern allows decoupled systems to react

### 3. Save/Load Integration

```gdscript
func save_state() -> Dictionary:
    return {
        "weapon": _serialize_item(equipped_items["weapon"]),
        "helmet": _serialize_item(equipped_items["helmet"]),
        # ... etc
    }

func _serialize_item(item: Variant) -> Variant:
    # Store only item ID (can reload from database)
    if item is Dictionary:
        return item.get("id", null)
    return null
```

**Why this works:**
- Saves only item IDs, not full data (smaller save files)
- Equipment database acts as source of truth
- Reloads item data from JSON on load
- Prevents save file bloat

### 4. Accessory Array Management

```gdscript
const MAX_ACCESSORIES: int = 3

func _equip_accessory(item_data: Dictionary) -> bool:
    var accessories = equipped_items["accessories"] as Array

    if accessories.size() >= MAX_ACCESSORIES:
        return false

    accessories.append(item_data)
    _recalculate_stats()
    return true

func unequip_accessory(index: int) -> bool:
    var accessories = equipped_items["accessories"] as Array
    if index < 0 or index >= accessories.size():
        return false

    accessories.remove_at(index)
    _recalculate_stats()
    return true
```

**Why this works:**
- Array allows flexible number of accessories (0-3)
- Index-based removal prevents issues with duplicate items
- Size check enforces maximum limit

---

## Key Decisions

### Decision 1: Custom Equipment System vs. Plugin
**Chosen:** Custom implementation
**Why:**
- S05 already uses GLoot for inventory
- Equipment needs specific integration with S03 (Player) and S04 (Combat)
- Custom system allows precise control over stat bonuses
- Lighter weight than full equipment plugin
- Easier to extend for S09 (Dodge/Block) and S25 (Crafting)

### Decision 2: Dictionary-Based Item Data vs. Custom Resources
**Chosen:** Dictionary-based (loaded from JSON)
**Why:**
- Consistent with S05 Inventory approach
- Easy to add new equipment without code changes
- JSON is human-readable and editable
- Can be loaded dynamically
- Tier 1 can create complete equipment database
- Resources would require Godot editor (Tier 2 only)

### Decision 3: Accessories as Array vs. Individual Slots
**Chosen:** Array with MAX_ACCESSORIES = 3
**Why:**
- More flexible than 3 separate slots
- Easier to extend max count later
- Simpler UI implementation
- Allows iterating over all accessories
- Matches common RPG pattern

### Decision 4: Stat Recalculation Strategy
**Chosen:** Full recalculation on every equip/unequip
**Why:**
- Simple and bug-resistant
- Performance cost is negligible (5 items max)
- Ensures stats are always correct
- No need to track deltas or differences
- Easy to debug

### Decision 5: Visual Equipment Integration
**Chosen:** Optional sprite_path in equipment data
**Why:**
- Some equipment won't have visible sprites (accessories)
- Allows gradual addition of visual equipment
- Signal emits sprite path when equipment changes
- S03 Player can listen and update sprite layers
- Not blocking for core functionality

---

## Integration Patterns

### With S03 (Player)
```gdscript
# EquipmentManager is child of Player node
# Player can access it directly
var equipment_manager = $EquipmentManager

# Listen to stat changes
equipment_manager.stats_changed.connect(_on_equipment_stats_changed)

func _on_equipment_stats_changed(new_stats: Dictionary):
    # Apply bonuses to player stats
    total_defense = base_defense + new_stats["defense"]
    max_hp = base_max_hp + new_stats["max_hp"]
    # etc.
```

### With S05 (Inventory)
```gdscript
# Equip item from inventory
func equip_from_inventory(item_id: String, slot: String):
    # Get item from inventory
    var inventory = get_node("/root/InventoryManager")

    # Equip it
    var equipment_manager = $EquipmentManager
    if equipment_manager.equip_item_by_id(slot, item_id):
        # Remove from inventory (only if equip succeeded)
        inventory.remove_item_by_id(item_id)
```

### With S06 (Save/Load)
```gdscript
# SaveManager calls equipment save/load
func save_game():
    var save_data = {}
    var equipment_manager = player.get_node("EquipmentManager")
    save_data["equipment"] = equipment_manager.save_state()

func load_game(save_data: Dictionary):
    if save_data.has("equipment"):
        var equipment_manager = player.get_node("EquipmentManager")
        equipment_manager.load_state(save_data["equipment"])
```

---

## Godot 4.5 Specifics

### GDScript 4.5 Syntax Used
1. **Type hints everywhere**:
   ```gdscript
   func equip_item(slot: String, item_data: Dictionary) -> bool
   var equipped_items: Dictionary = {}
   ```

2. **Typed arrays**:
   ```gdscript
   var accessories: Array = []  # Generic Array (holds Dictionaries)
   ```

3. **Signals with typed parameters**:
   ```gdscript
   signal item_equipped(slot: String, item_data: Dictionary)
   signal stats_changed(new_stats: Dictionary)
   ```

4. **Dictionary operations**:
   ```gdscript
   item_data.get("stat_bonuses", {}) as Dictionary
   current_stat_bonuses.has("defense")
   ```

5. **Variant type for nullable returns**:
   ```gdscript
   func _serialize_item(item: Variant) -> Variant
   ```

### Changed from Godot 3.x
- No `export` keyword (not needed for this system)
- Use `@onready` for node references (if any)
- JSON parsing uses `JSON.new()` then `parse()`
- FileAccess.open() instead of File.new()
- Dictionary.is_empty() instead of empty()

---

## Testing Strategy

### Unit Tests (to be implemented by Tier 2)
1. **Test equipment database loading**
   - Verify all 23 items load correctly
   - Check item structure (id, name, slot, stat_bonuses)

2. **Test equip/unequip mechanics**
   - Equip item in each slot
   - Unequip item from each slot
   - Verify slot validation (wrong item type)

3. **Test stat calculation**
   - Equip items with known bonuses
   - Verify total stats match expected values
   - Test negative bonuses (speed penalty)

4. **Test accessories**
   - Equip 3 accessories successfully
   - Try to equip 4th (should fail)
   - Unequip by index

5. **Test save/load**
   - Equip items
   - Save state
   - Clear equipment
   - Load state
   - Verify equipment restored

### Integration Tests
1. **Player integration**: Verify EquipmentManager adds to Player node
2. **Inventory integration**: Test equip from inventory, unequip to inventory
3. **Combat integration**: Verify stat bonuses apply to combat calculations
4. **Save/Load integration**: Test full game save/load preserves equipment

---

## Gotchas for Tier 2

1. **Equipment Database Path**: Must be `res://data/equipment.json` (not `data/equipment.json`)

2. **Accessories Slot Name**: Use string "accessories" (plural) for slot name, but item JSON uses "accessory" (singular) for slot type

3. **Stat Bonuses Can Be Negative**: Speed penalties on heavy armor are negative values - UI should handle this

4. **Weight System**: Total weight calculated but not yet used - future integration with movement speed

5. **Visual Equipment**: sprite_path can be empty string - check before loading texture

6. **Signal Timing**: stats_changed emits after equip/unequip, not before - listeners get updated stats

7. **Save/Load Order**: Equipment must be loaded AFTER equipment database loads (in _ready)

---

## Performance Considerations

- **Equipment Database**: Loaded once at startup, ~23 items, minimal memory
- **Stat Recalculation**: O(n) where n = equipped items (max 7), runs on equip/unequip only
- **Dictionary Operations**: Fast lookups, negligible performance impact
- **Signal Emissions**: Only on equipment changes, not per-frame
- **Expected Performance**: <0.01ms per equip/unequip operation

---

## Future Enhancements (Not in S08 Scope)

1. **Drag-Drop UI** (referenced in HANDOFF):
   - Implement Control._get_drag_data()
   - Implement Control._can_drop_data()
   - Implement Control._drop_data()
   - Visual drag preview

2. **Equipment Sets** (for S25 Crafting):
   - Set bonuses when wearing multiple pieces
   - Example: "Iron Set" bonus when wearing 3+ iron items

3. **Equipment Durability**:
   - Items degrade over time
   - Repair system

4. **Equipment Enhancement** (S25 Crafting):
   - Upgrade equipment stats
   - Add enchantments

5. **Visual Equipment Layers**:
   - Helmet sprite layer on player
   - Torso sprite layer
   - Dynamic sprite composition

6. **Equipment Requirements**:
   - Level requirements
   - Stat requirements (need 10 STR to equip)

---

## Reusable Patterns for Other Systems

### Pattern 1: JSON Database Loading
The equipment database pattern can be reused for:
- S12 (Monster Database)
- S24 (Cooking recipes)
- S25 (Crafting recipes)

### Pattern 2: Stat Bonus Calculation
The additive stat bonus pattern can be used for:
- S09 (Dodge/Block modifiers)
- S19 (Level-up stat increases)
- S21 (Alignment bonuses)
- Status effects (buffs/debuffs)

### Pattern 3: Save/Load by ID
The "save ID, reload from database" pattern is efficient for:
- Any system with a large data definition
- Systems where data doesn't change at runtime
- Prevents save file bloat

### Pattern 4: Signal-Based Integration
The stats_changed signal pattern allows:
- Loose coupling between systems
- Multiple listeners (UI, Combat, etc.)
- Easy to add new integrations later

---

## References

### Documentation
- Godot 4.5 Signal Documentation: https://docs.godotengine.org/en/4.5/classes/class_signal.html
- Godot 4.5 JSON Parsing: https://docs.godotengine.org/en/4.5/classes/class_json.html
- Godot 4.5 FileAccess: https://docs.godotengine.org/en/4.5/classes/class_fileaccess.html

### Tutorials
- Modular Stat System: https://medium.com/@minoqi/modular-stat-attribute-system-tutorial-for-godot-4-0bac1c5062ce
- Drag-Drop in Godot 4: https://dev.to/pdeveloper/godot-4x-drag-and-drop-5g13
- Tactics RPG Stats: https://theliquidfire.com/2024/10/10/godot-tactics-rpg-09-stats/

### Assets
- Drag-Drop Inventory: https://godotengine.org/asset-library/asset/2026
- Enhanced Stat Addon: https://godotengine.org/asset-library/asset/2076
- GLoot Plugin: (used by S05)

---

**Research Complete**
**Total Time:** 45 minutes
**Next Step:** Implementation (completed)
**Status:** Ready for Tier 2 scene configuration
