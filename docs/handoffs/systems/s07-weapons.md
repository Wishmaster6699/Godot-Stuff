# HANDOFF: S07 - Weapons & Shields Database
**From:** Tier 1 (Claude Code Web)
**To:** Tier 2 (Godot MCP Agent)
**Date:** 2025-11-18
**Status:** READY FOR TIER 2

---

## System Overview

**Purpose:** Data-driven database of 50+ weapons and 16 shields with complete combat stats
**Type:** Resource System + Autoload Singleton
**Dependencies:** None (foundation data system)
**Blocks:** S08 (Equipment), S10 (Special Moves), S25 (Crafting)

This system provides a centralized, JSON-based database for all weapons and shields in the game. The ItemDatabase autoload loads all item definitions at startup and caches them as typed Resource instances for fast O(1) lookup and type-safe access throughout the game.

---

## Files Created by Tier 1

### GDScript Files
- ✅ `res://resources/weapon_resource.gd` - WeaponResource class definition
  - Properties: id, name, type, tier, damage, speed, range, attack_pattern, special_effects, icon_path, value
  - Methods: get_description(), has_effect(), get_dps(), duplicate_weapon()

- ✅ `res://resources/shield_resource.gd` - ShieldResource class definition
  - Properties: id, name, type, tier, defense, block_percentage, weight, special_properties, icon_path, value
  - Methods: get_description(), has_property(), calculate_damage_reduction(), get_speed_penalty(), duplicate_shield()

- ✅ `res://autoloads/item_database.gd` - ItemDatabase singleton autoload
  - Loads weapons.json and shields.json at startup
  - Caches all items as Resource instances
  - Methods: get_weapon(id), get_shield(id), get_all_weapons(), get_all_shields(), get_weapons_by_type(), get_shields_by_type(), get_weapons_by_tier(), get_shields_by_tier()

### JSON Data Files
- ✅ `res://data/weapons.json` - 50 weapon definitions
  - 10 swords (wooden_sword → excalibur, legendary_blade)
  - 8 axes (hand_axe → mjolnir)
  - 8 spears (wooden_spear → gungnir)
  - 8 bows (short_bow → artemis_bow)
  - 8 staves (wooden_staff → staff_of_the_ancients)
  - 8 legendary weapons (soul_reaper, chaos_blade, phoenix_blade, infinity_edge, starlight_saber, dawn_breaker, night_fall, world_ender)

- ✅ `res://data/shields.json` - 16 shield definitions
  - 5 small shields (wooden_buckler → aegis_buckler)
  - 6 medium shields (wooden_shield → guardian_shield)
  - 5 large shields (tower_shield → world_shield, divine_bulwark)

### Research Documentation
- ✅ `research/s07-weapons-research.md` - Research findings and patterns

**All files validated:** Syntax ✓ | Type hints ✓ | Documentation ✓ | JSON valid ✓

---

## Godot MCP Commands for Tier 2

### Step 1: Register ItemDatabase Autoload

**CRITICAL:** ItemDatabase must be registered as autoload in project.godot

**Manual Step Required:**
Edit `project.godot` and add under `[autoload]` section:

```ini
[autoload]
ItemDatabase="*res://autoloads/item_database.gd"
```

**Verification:**
After adding, the ItemDatabase should be accessible globally in any script with `ItemDatabase.get_weapon("wooden_sword")`

---

### Step 2: Create Test Scene for Weapons Display

Create a test scene to verify all weapons and shields load correctly and display their stats.

```python
# Create test scene with UI layout
create_scene("res://tests/test_weapons_database.tscn", "Control")

# Add main container
add_node("res://tests/test_weapons_database.tscn", "VBoxContainer", "MainLayout", ".")
update_property("res://tests/test_weapons_database.tscn", "MainLayout", "anchors_preset", 15)  # Full rect
update_property("res://tests/test_weapons_database.tscn", "MainLayout", "offset_left", 10)
update_property("res://tests/test_weapons_database.tscn", "MainLayout", "offset_top", 10)
update_property("res://tests/test_weapons_database.tscn", "MainLayout", "offset_right", -10)
update_property("res://tests/test_weapons_database.tscn", "MainLayout", "offset_bottom", -10)

# Add title label
add_node("res://tests/test_weapons_database.tscn", "Label", "Title", "MainLayout")
update_property("res://tests/test_weapons_database.tscn", "Title", "text", "S07 - Weapons & Shields Database Test")
update_property("res://tests/test_weapons_database.tscn", "Title", "horizontal_alignment", 1)  # Center
add_node("res://tests/test_weapons_database.tscn", "HSeparator", "Sep1", "MainLayout")

# Add stats display
add_node("res://tests/test_weapons_database.tscn", "Label", "Stats", "MainLayout")
update_property("res://tests/test_weapons_database.tscn", "Stats", "text", "Loading...")

# Add scroll container for items
add_node("res://tests/test_weapons_database.tscn", "ScrollContainer", "ScrollArea", "MainLayout")
update_property("res://tests/test_weapons_database.tscn", "ScrollArea", "size_flags_vertical", 3)  # Expand

# Add tab container for weapon categories
add_node("res://tests/test_weapons_database.tscn", "TabContainer", "CategoryTabs", "ScrollArea")

# Swords tab
add_node("res://tests/test_weapons_database.tscn", "VBoxContainer", "SwordsTab", "CategoryTabs")
update_property("res://tests/test_weapons_database.tscn", "SwordsTab", "name", "Swords (10)")

# Axes tab
add_node("res://tests/test_weapons_database.tscn", "VBoxContainer", "AxesTab", "CategoryTabs")
update_property("res://tests/test_weapons_database.tscn", "AxesTab", "name", "Axes (8)")

# Spears tab
add_node("res://tests/test_weapons_database.tscn", "VBoxContainer", "SpearsTab", "CategoryTabs")
update_property("res://tests/test_weapons_database.tscn", "SpearsTab", "name", "Spears (8)")

# Bows tab
add_node("res://tests/test_weapons_database.tscn", "VBoxContainer", "BowsTab", "CategoryTabs")
update_property("res://tests/test_weapons_database.tscn", "BowsTab", "name", "Bows (8)")

# Staves tab
add_node("res://tests/test_weapons_database.tscn", "VBoxContainer", "StavesTab", "CategoryTabs")
update_property("res://tests/test_weapons_database.tscn", "StavesTab", "name", "Staves (8)")

# Legendary tab
add_node("res://tests/test_weapons_database.tscn", "VBoxContainer", "LegendaryTab", "CategoryTabs")
update_property("res://tests/test_weapons_database.tscn", "LegendaryTab", "name", "Legendary (8)")

# Shields tab
add_node("res://tests/test_weapons_database.tscn", "VBoxContainer", "ShieldsTab", "CategoryTabs")
update_property("res://tests/test_weapons_database.tscn", "ShieldsTab", "name", "Shields (16)")

# Add detail panel
add_node("res://tests/test_weapons_database.tscn", "Panel", "DetailPanel", "MainLayout")
update_property("res://tests/test_weapons_database.tscn", "DetailPanel", "custom_minimum_size", "Vector2(0, 200)")

add_node("res://tests/test_weapons_database.tscn", "VBoxContainer", "DetailLayout", "DetailPanel")
update_property("res://tests/test_weapons_database.tscn", "DetailLayout", "offset_left", 10)
update_property("res://tests/test_weapons_database.tscn", "DetailLayout", "offset_top", 10)
update_property("res://tests/test_weapons_database.tscn", "DetailLayout", "offset_right", -10)
update_property("res://tests/test_weapons_database.tscn", "DetailLayout", "offset_bottom", -10)

add_node("res://tests/test_weapons_database.tscn", "Label", "DetailTitle", "DetailLayout")
update_property("res://tests/test_weapons_database.tscn", "DetailTitle", "text", "Item Details")
update_property("res://tests/test_weapons_database.tscn", "DetailTitle", "horizontal_alignment", 1)

add_node("res://tests/test_weapons_database.tscn", "RichTextLabel", "DetailText", "DetailLayout")
update_property("res://tests/test_weapons_database.tscn", "DetailText", "size_flags_vertical", 3)
update_property("res://tests/test_weapons_database.tscn", "DetailText", "bbcode_enabled", true)
update_property("res://tests/test_weapons_database.tscn", "DetailText", "text", "Select an item to view details")
```

---

### Step 3: Create Test Script

Create `res://tests/test_weapons_database.gd` to populate the UI with data:

```gdscript
# Godot 4.5 | GDScript 4.5
# Test script for S07 - Weapons & Shields Database
# Displays all weapons and shields in categorized tabs

extends Control


func _ready() -> void:
	# Update stats
	var weapon_count := ItemDatabase.get_weapon_count()
	var shield_count := ItemDatabase.get_shield_count()
	$MainLayout/Stats.text = "Loaded: %d weapons, %d shields" % [weapon_count, shield_count]

	# Populate tabs
	_populate_weapons_tab("sword", $MainLayout/ScrollArea/CategoryTabs/SwordsTab)
	_populate_weapons_tab("axe", $MainLayout/ScrollArea/CategoryTabs/AxesTab)
	_populate_weapons_tab("spear", $MainLayout/ScrollArea/CategoryTabs/SpearsTab)
	_populate_weapons_tab("bow", $MainLayout/ScrollArea/CategoryTabs/BowsTab)
	_populate_weapons_tab("staff", $MainLayout/ScrollArea/CategoryTabs/StavesTab)
	_populate_weapons_tab("legendary", $MainLayout/ScrollArea/CategoryTabs/LegendaryTab)
	_populate_shields_tab($MainLayout/ScrollArea/CategoryTabs/ShieldsTab)

	# Print debug stats
	ItemDatabase.print_database_stats()


func _populate_weapons_tab(weapon_type: String, container: VBoxContainer) -> void:
	var weapons := ItemDatabase.get_weapons_by_type(weapon_type)

	for weapon in weapons:
		var button := Button.new()
		button.text = "%s (T%d) - DMG:%d SPD:%.1f RNG:%d" % [
			weapon.name, weapon.tier, weapon.damage, weapon.speed, weapon.range
		]
		button.pressed.connect(_on_weapon_selected.bind(weapon))
		container.add_child(button)


func _populate_shields_tab(container: VBoxContainer) -> void:
	var shields := ItemDatabase.get_all_shields()

	for shield in shields:
		var button := Button.new()
		button.text = "%s (%s, T%d) - DEF:%d BLK:%.0f%% WT:%.1f" % [
			shield.name, shield.type.capitalize(), shield.tier,
			shield.defense, shield.block_percentage * 100, shield.weight
		]
		button.pressed.connect(_on_shield_selected.bind(shield))
		container.add_child(button)


func _on_weapon_selected(weapon: WeaponResource) -> void:
	$MainLayout/DetailPanel/DetailLayout/DetailText.text = weapon.get_description()


func _on_shield_selected(shield: ShieldResource) -> void:
	$MainLayout/DetailPanel/DetailLayout/DetailText.text = shield.get_description()
```

Attach this script using:
```python
attach_script("res://tests/test_weapons_database.tscn", "Control", "res://tests/test_weapons_database.gd")
```

---

## Node Hierarchies

### Test Scene Structure
```
Control (test_weapons_database.tscn)
└── VBoxContainer (MainLayout) [anchors: full rect]
    ├── Label (Title) - "S07 - Weapons & Shields Database Test"
    ├── HSeparator (Sep1)
    ├── Label (Stats) - "Loaded: X weapons, Y shields"
    ├── ScrollContainer (ScrollArea) [expand fill]
    │   └── TabContainer (CategoryTabs)
    │       ├── VBoxContainer (SwordsTab) [name: "Swords (10)"]
    │       ├── VBoxContainer (AxesTab) [name: "Axes (8)"]
    │       ├── VBoxContainer (SpearsTab) [name: "Spears (8)"]
    │       ├── VBoxContainer (BowsTab) [name: "Bows (8)"]
    │       ├── VBoxContainer (StavesTab) [name: "Staves (8)"]
    │       ├── VBoxContainer (LegendaryTab) [name: "Legendary (8)"]
    │       └── VBoxContainer (ShieldsTab) [name: "Shields (16)"]
    └── Panel (DetailPanel) [min_size: (0, 200)]
        └── VBoxContainer (DetailLayout)
            ├── Label (DetailTitle) - "Item Details"
            └── RichTextLabel (DetailText) - BBCode enabled

Note: Buttons are added dynamically by script
```

---

## Property Configurations

### Critical Properties

**ItemDatabase (autoload):**
- Loads at startup automatically when registered
- No configuration needed - data paths are const

**Test Scene:**
- MainLayout: anchors_preset = 15 (full rect), margins = 10px
- ScrollArea: size_flags_vertical = 3 (expand fill)
- DetailPanel: custom_minimum_size = Vector2(0, 200)
- DetailText: bbcode_enabled = true, size_flags_vertical = 3

---

## Integration Notes

### How Other Systems Should Use This

**Combat System (S04):**
```gdscript
# Get weapon damage for combat calculations
var weapon := ItemDatabase.get_weapon("iron_sword")
if weapon:
    var damage_dealt := weapon.damage
    # Apply speed modifier: faster weapons = more attacks
```

**Inventory System (S05):**
```gdscript
# Display weapon in inventory UI
var weapon := ItemDatabase.get_weapon(item_id)
if weapon:
    inventory_icon.texture = load(weapon.icon_path)
    inventory_label.text = weapon.name
    tooltip.text = weapon.get_description()
```

**Equipment System (S08):**
```gdscript
# Equip weapon
func equip_weapon(weapon_id: String) -> void:
    var weapon := ItemDatabase.get_weapon(weapon_id)
    if weapon:
        equipped_weapon = weapon
        update_combat_stats()

# Calculate total defense with shield
func equip_shield(shield_id: String) -> void:
    var shield := ItemDatabase.get_shield(shield_id)
    if shield:
        equipped_shield = shield
        defense_bonus = shield.defense
        movement_speed *= shield.get_speed_penalty()
```

**Dodge/Block System (S09):**
```gdscript
# Use shield block percentage
func attempt_block() -> bool:
    if equipped_shield:
        return randf() < equipped_shield.block_percentage
    return false

func calculate_blocked_damage(damage: int) -> int:
    if equipped_shield:
        return equipped_shield.calculate_damage_reduction(damage)
    return 0
```

**Special Moves System (S10):**
```gdscript
# Get weapon-specific special moves
func get_available_special_moves() -> Array:
    var moves: Array = []
    if equipped_weapon and equipped_weapon.type == "sword":
        moves.append("Sword Dance")
    elif equipped_weapon and equipped_weapon.has_effect("fire_damage"):
        moves.append("Flame Burst")
    return moves
```

**Crafting System (S25):**
```gdscript
# Create enhanced weapon
func craft_enhanced_weapon(base_id: String) -> WeaponResource:
    var base := ItemDatabase.get_weapon(base_id)
    if base:
        var enhanced := base.duplicate_weapon()
        enhanced.id = base.id + "_enhanced"
        enhanced.name = base.name + " +"
        enhanced.damage += 5
        enhanced.tier += 1
        enhanced.special_effects.append("enhanced")
        return enhanced
    return null
```

---

## Testing Checklist for Tier 2

**Before marking complete, Tier 2 agent MUST verify:**

### Autoload Registration
- [ ] ItemDatabase registered in project.godot `[autoload]` section
- [ ] ItemDatabase accessible globally: `ItemDatabase.get_weapon("wooden_sword")` works in any script
- [ ] No errors in Godot console when opening project

### JSON Loading
- [ ] weapons.json loads without errors (check console for JSON parse errors)
- [ ] shields.json loads without errors
- [ ] ItemDatabase prints "Loaded X weapons and Y shields" on startup
- [ ] Verify counts: 50 weapons, 16 shields

### Resource Instantiation
- [ ] All weapons cached as WeaponResource instances
- [ ] All shields cached as ShieldResource instances
- [ ] `get_weapon("iron_sword")` returns valid WeaponResource
- [ ] `get_shield("wooden_shield")` returns valid ShieldResource
- [ ] Invalid IDs return null with warning

### Test Scene
- [ ] Test scene runs without errors: `play_scene("res://tests/test_weapons_database.tscn")`
- [ ] All 7 tabs display (Swords, Axes, Spears, Bows, Staves, Legendary, Shields)
- [ ] Correct weapon counts in each tab (10, 8, 8, 8, 8, 8, 16)
- [ ] Clicking weapon/shield button displays description in detail panel
- [ ] All weapons have complete stats (no missing fields)
- [ ] All shields have complete stats (no missing fields)

### Data Quality Verification
- [ ] Weapon stats vary by tier: Tier 1 (5-10 dmg) → Tier 5 (40-60 dmg)
- [ ] Shield stats vary by tier: Tier 1 (5-12 def) → Tier 5 (25-38 def)
- [ ] Weapon types distributed: 10 swords, 8 axes, 8 spears, 8 bows, 8 staves, 8 legendary
- [ ] Shield types distributed: 5 small, 6 medium, 5 large
- [ ] No duplicate IDs (all weapons and shields have unique IDs)
- [ ] Special effects stored as arrays
- [ ] All required JSON fields present

### Functionality Testing
- [ ] `get_all_weapons()` returns 50 weapons
- [ ] `get_all_shields()` returns 16 shields
- [ ] `get_weapons_by_type("sword")` returns 10 swords
- [ ] `get_shields_by_type("small")` returns 5 small shields
- [ ] `get_weapons_by_tier(5)` returns legendary tier weapons
- [ ] `has_weapon("excalibur")` returns true
- [ ] `has_weapon("nonexistent")` returns false
- [ ] `print_database_stats()` displays correct statistics

### Integration Tests
- [ ] Run integration tests: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S07")`
- [ ] Quality gates: `check_quality_gates("S07")`
- [ ] Checkpoint validation: `validate_checkpoint("S07")`

**Expected Results:**
- Integration tests: PASS
- Performance: <0.1ms load time, negligible runtime overhead
- Quality score: ≥80/100 (passing threshold)

---

## Gotchas & Known Issues

### Godot 4.5 Specific
- JSON parsing uses `JSON.new()` pattern (not Godot 3.x `parse_json()`)
- FileAccess API: Use `FileAccess.open()` not `File.new()`
- Typed arrays: `Array[String]` syntax for special_effects
- Resource class must use `class_name` for registration

### System-Specific
- **Shared Resources:** Resource instances are shared across the game. Don't modify weapon stats directly at runtime - use `duplicate_weapon()` if you need a modified copy
- **JSON Validation:** JSON syntax errors will crash at startup - validate JSON before testing
- **Icon Paths:** All icon paths are placeholders - actual assets don't exist yet (use ASSET-PIPELINE.md for placeholder generation)
- **No Duplicate Checking:** ItemDatabase doesn't check for duplicate IDs - ensure JSON has unique IDs

### Integration Warnings
- **S04 Combat:** Must handle null weapon (unarmed combat) gracefully
- **S05 Inventory:** Icon paths point to non-existent assets - display placeholder or fallback texture
- **S08 Equipment:** Equipping shields affects movement speed via `get_speed_penalty()`
- **S25 Crafting:** Use `duplicate_weapon()` to create modified weapons - don't mutate originals

### Performance Notes
- All items loaded at startup - acceptable for 66 total items
- O(1) lookup by ID (dictionary-based)
- Filtering by type/tier uses O(n) iteration - cache results if needed frequently

---

## Research References

**Tier 1 Research Summary:**
- Godot 4.5 Resources: https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- JSON Class: https://docs.godotengine.org/en/4.4/classes/class_json.html
- GDScript Exports: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html
- Custom Resources Tutorial: https://ezcha.net/news/3-1-23-custom-resources-are-op-in-godot-4
- JSON in Godot: https://gamedevacademy.org/json-in-godot-complete-guide/

**Full research notes:** `research/s07-weapons-research.md`

---

## Verification Evidence Required

**Tier 2 must provide:**
1. Screenshot of test scene running with all tabs visible (`get_editor_screenshot()`)
2. Screenshot showing weapon details panel populated
3. Error log output (`get_godot_errors()`) - should be empty or warnings only
4. Console output showing "Loaded 50 weapons and 16 shields"
5. Database stats output from `print_database_stats()`

**Save to:** `evidence/S07-tier2-verification/`

---

## Completion Criteria

**System S07 is complete when:**
- ✅ ItemDatabase autoload registered and accessible globally
- ✅ weapons.json loads successfully (50 weapons)
- ✅ shields.json loads successfully (16 shields)
- ✅ Test scene runs without errors
- ✅ All weapon categories populated correctly
- ✅ All shield categories populated correctly
- ✅ Item details display when clicked
- ✅ Integration tests pass
- ✅ Performance meets targets (<0.1ms load)
- ✅ Quality gates pass (score ≥80)
- ✅ Documentation complete (checkpoint.md)
- ✅ Unblocked systems notified: S08, S10, S25

**Next Steps:**
- S08 Equipment can access weapon/shield resources for equipping
- S10 Special Moves can filter weapons by type for special attacks
- S25 Crafting can duplicate and modify weapons
- S04 Combat can use weapon damage in calculations
- S05 Inventory can display weapon/shield icons

---

## Data Extensibility

### Adding New Weapons
Simply add JSON entry to `res://data/weapons.json` - **no code changes needed**:

```json
{
  "id": "mythril_sword",
  "name": "Mythril Sword",
  "type": "sword",
  "tier": 3,
  "damage": 24,
  "speed": 0.9,
  "range": 38,
  "attack_pattern": "slash",
  "special_effects": ["lightweight", "magic_resist"],
  "icon_path": "res://assets/icons/weapons/mythril_sword.png",
  "value": 350
}
```

### Adding New Shields
Simply add JSON entry to `res://data/shields.json`:

```json
{
  "id": "crystal_shield",
  "name": "Crystal Shield",
  "type": "medium",
  "tier": 4,
  "defense": 20,
  "block_percentage": 0.52,
  "weight": 2.8,
  "special_properties": ["magic_reflect", "transparent"],
  "icon_path": "res://assets/icons/shields/crystal_shield.png",
  "value": 1050
}
```

### Testing New Items
1. Add JSON entry
2. Restart Godot (reloads ItemDatabase)
3. Run test scene - new item appears in appropriate tab
4. No code changes required!

---

**HANDOFF STATUS: READY FOR TIER 2**
**Estimated Tier 2 Time:** 2-3 hours (autoload registration + scene config + testing)
**Priority:** HIGH (blocks S08 Equipment, S10 Special Moves, S25 Crafting)

---

*Generated by: Claude Code Web Agent*
*Date: 2025-11-18*
*Prompt: 009-s07-weapons-database.md*
*System: S07 - Weapons & Shields Database*
