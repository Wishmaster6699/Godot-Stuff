# HANDOFF: S08 - Equipment System
**From:** Tier 1 (Claude Code Web)
**To:** Tier 2 (Godot MCP Agent)
**Date:** 2025-11-18
**Status:** READY FOR TIER 2

---

## System Overview

**Purpose:** Equipment system with 5 slots (weapon, helmet, torso, boots, accessories) that provides stat bonuses and integrates with inventory
**Type:** Component (attaches to Player) + UI Scenes
**Dependencies:** S03 (Player), S05 (Inventory), S07 (Weapons Database)

---

## Files Created by Tier 1

### GDScript Files
- ✅ `src/systems/s08-equipment/equipment_manager.gd` - Complete EquipmentManager with 5 slots, stat calculation, save/load integration

### JSON Data Files
- ✅ `data/equipment.json` - 23 equipment definitions (helmets, torsos, boots, accessories with stat bonuses)

**All files validated:** Syntax ✓ | Type hints ✓ | Documentation ✓ | GDScript 4.5 compliant ✓

---

## Godot MCP Commands for Tier 2

### Step 1: Attach EquipmentManager to Player

**Note:** EquipmentManager should be added as a child node to the Player scene created in S03.

```bash
# Open player scene
open_scene res://player/player.tscn

# Add EquipmentManager node as child of Player root
add_node res://player/player.tscn EquipmentManager EquipmentManager Player

# Attach equipment_manager.gd script
attach_script res://player/player.tscn EquipmentManager res://src/systems/s08-equipment/equipment_manager.gd

# Save player scene
# (Godot auto-saves, but verify with get_scene_tree)
```

### Step 2: Create Equipment Panel UI

```bash
# Create equipment panel scene
create_scene res://scenes/s08-equipment/equipment_panel.tscn Node2D

# Change root to Panel (UI control)
# Note: You may need to delete Node2D and create Panel as root instead
add_node res://scenes/s08-equipment/equipment_panel.tscn Panel EquipmentPanel root

# Add main layout
add_node res://scenes/s08-equipment/equipment_panel.tscn VBoxContainer MainLayout EquipmentPanel
add_node res://scenes/s08-equipment/equipment_panel.tscn Label Title MainLayout

# Add equipment slots container
add_node res://scenes/s08-equipment/equipment_panel.tscn VBoxContainer EquipmentSlots MainLayout

# Weapon slot
add_node res://scenes/s08-equipment/equipment_panel.tscn HBoxContainer WeaponSlotRow EquipmentSlots
add_node res://scenes/s08-equipment/equipment_panel.tscn Label WeaponLabel WeaponSlotRow
add_node res://scenes/s08-equipment/equipment_panel.tscn PanelContainer WeaponSlot WeaponSlotRow
add_node res://scenes/s08-equipment/equipment_panel.tscn TextureRect WeaponIcon WeaponSlot
add_node res://scenes/s08-equipment/equipment_panel.tscn Label WeaponName WeaponSlotRow

# Helmet slot
add_node res://scenes/s08-equipment/equipment_panel.tscn HBoxContainer HelmetSlotRow EquipmentSlots
add_node res://scenes/s08-equipment/equipment_panel.tscn Label HelmetLabel HelmetSlotRow
add_node res://scenes/s08-equipment/equipment_panel.tscn PanelContainer HelmetSlot HelmetSlotRow
add_node res://scenes/s08-equipment/equipment_panel.tscn TextureRect HelmetIcon HelmetSlot
add_node res://scenes/s08-equipment/equipment_panel.tscn Label HelmetName HelmetSlotRow

# Torso slot
add_node res://scenes/s08-equipment/equipment_panel.tscn HBoxContainer TorsoSlotRow EquipmentSlots
add_node res://scenes/s08-equipment/equipment_panel.tscn Label TorsoLabel TorsoSlotRow
add_node res://scenes/s08-equipment/equipment_panel.tscn PanelContainer TorsoSlot TorsoSlotRow
add_node res://scenes/s08-equipment/equipment_panel.tscn TextureRect TorsoIcon TorsoSlot
add_node res://scenes/s08-equipment/equipment_panel.tscn Label TorsoName TorsoSlotRow

# Boots slot
add_node res://scenes/s08-equipment/equipment_panel.tscn HBoxContainer BootsSlotRow EquipmentSlots
add_node res://scenes/s08-equipment/equipment_panel.tscn Label BootsLabel BootsSlotRow
add_node res://scenes/s08-equipment/equipment_panel.tscn PanelContainer BootsSlot BootsSlotRow
add_node res://scenes/s08-equipment/equipment_panel.tscn TextureRect BootsIcon BootsSlot
add_node res://scenes/s08-equipment/equipment_panel.tscn Label BootsName BootsSlotRow

# Accessories section
add_node res://scenes/s08-equipment/equipment_panel.tscn Label AccessoriesTitle MainLayout
add_node res://scenes/s08-equipment/equipment_panel.tscn HBoxContainer AccessorySlots MainLayout

# Accessory slots (3 total)
add_node res://scenes/s08-equipment/equipment_panel.tscn PanelContainer Accessory1Slot AccessorySlots
add_node res://scenes/s08-equipment/equipment_panel.tscn TextureRect Accessory1Icon Accessory1Slot

add_node res://scenes/s08-equipment/equipment_panel.tscn PanelContainer Accessory2Slot AccessorySlots
add_node res://scenes/s08-equipment/equipment_panel.tscn TextureRect Accessory2Icon Accessory2Slot

add_node res://scenes/s08-equipment/equipment_panel.tscn PanelContainer Accessory3Slot AccessorySlots
add_node res://scenes/s08-equipment/equipment_panel.tscn TextureRect Accessory3Icon Accessory3Slot

# Stats display section
add_node res://scenes/s08-equipment/equipment_panel.tscn VBoxContainer StatsDisplay MainLayout
add_node res://scenes/s08-equipment/equipment_panel.tscn Label StatsTitle StatsDisplay
add_node res://scenes/s08-equipment/equipment_panel.tscn Label StatDefense StatsDisplay
add_node res://scenes/s08-equipment/equipment_panel.tscn Label StatMaxHP StatsDisplay
add_node res://scenes/s08-equipment/equipment_panel.tscn Label StatSpeed StatsDisplay
add_node res://scenes/s08-equipment/equipment_panel.tscn Label StatAttack StatsDisplay
add_node res://scenes/s08-equipment/equipment_panel.tscn Label StatMaxMP StatsDisplay
add_node res://scenes/s08-equipment/equipment_panel.tscn Label TotalWeight StatsDisplay
```

### Step 3: Configure Equipment Panel Properties

```bash
# Panel configuration
update_property res://scenes/s08-equipment/equipment_panel.tscn EquipmentPanel custom_minimum_size Vector2(500,700)
update_property res://scenes/s08-equipment/equipment_panel.tscn EquipmentPanel offset_right 500
update_property res://scenes/s08-equipment/equipment_panel.tscn EquipmentPanel offset_bottom 700

# Main layout
update_property res://scenes/s08-equipment/equipment_panel.tscn MainLayout custom_minimum_size Vector2(480,680)

# Title
update_property res://scenes/s08-equipment/equipment_panel.tscn Title text "Equipment"
update_property res://scenes/s08-equipment/equipment_panel.tscn Title horizontal_alignment 1

# Equipment slot labels
update_property res://scenes/s08-equipment/equipment_panel.tscn WeaponLabel text "Weapon:"
update_property res://scenes/s08-equipment/equipment_panel.tscn WeaponLabel custom_minimum_size Vector2(100,0)

update_property res://scenes/s08-equipment/equipment_panel.tscn HelmetLabel text "Helmet:"
update_property res://scenes/s08-equipment/equipment_panel.tscn HelmetLabel custom_minimum_size Vector2(100,0)

update_property res://scenes/s08-equipment/equipment_panel.tscn TorsoLabel text "Torso:"
update_property res://scenes/s08-equipment/equipment_panel.tscn TorsoLabel custom_minimum_size Vector2(100,0)

update_property res://scenes/s08-equipment/equipment_panel.tscn BootsLabel text "Boots:"
update_property res://scenes/s08-equipment/equipment_panel.tscn BootsLabel custom_minimum_size Vector2(100,0)

# Equipment slot sizes
update_property res://scenes/s08-equipment/equipment_panel.tscn WeaponSlot custom_minimum_size Vector2(64,64)
update_property res://scenes/s08-equipment/equipment_panel.tscn HelmetSlot custom_minimum_size Vector2(64,64)
update_property res://scenes/s08-equipment/equipment_panel.tscn TorsoSlot custom_minimum_size Vector2(64,64)
update_property res://scenes/s08-equipment/equipment_panel.tscn BootsSlot custom_minimum_size Vector2(64,64)

# Accessory slots
update_property res://scenes/s08-equipment/equipment_panel.tscn AccessoriesTitle text "Accessories (Max 3)"
update_property res://scenes/s08-equipment/equipment_panel.tscn AccessoriesTitle horizontal_alignment 1

update_property res://scenes/s08-equipment/equipment_panel.tscn Accessory1Slot custom_minimum_size Vector2(48,48)
update_property res://scenes/s08-equipment/equipment_panel.tscn Accessory2Slot custom_minimum_size Vector2(48,48)
update_property res://scenes/s08-equipment/equipment_panel.tscn Accessory3Slot custom_minimum_size Vector2(48,48)

# Stats display
update_property res://scenes/s08-equipment/equipment_panel.tscn StatsTitle text "Total Stats Bonuses"
update_property res://scenes/s08-equipment/equipment_panel.tscn StatsTitle horizontal_alignment 1

update_property res://scenes/s08-equipment/equipment_panel.tscn StatDefense text "Defense: +0"
update_property res://scenes/s08-equipment/equipment_panel.tscn StatMaxHP text "Max HP: +0"
update_property res://scenes/s08-equipment/equipment_panel.tscn StatSpeed text "Speed: +0"
update_property res://scenes/s08-equipment/equipment_panel.tscn StatAttack text "Attack: +0"
update_property res://scenes/s08-equipment/equipment_panel.tscn StatMaxMP text "Max MP: +0"
update_property res://scenes/s08-equipment/equipment_panel.tscn TotalWeight text "Weight: 0.0 kg"
```

### Step 4: Create Test Scene

```bash
# Create test scene
create_scene res://scenes/s08-equipment/test_equipment.tscn Node2D

# Add player instance (from S03)
add_scene res://scenes/s08-equipment/test_equipment.tscn Player root res://player/player.tscn

# Add UI layer
add_node res://scenes/s08-equipment/test_equipment.tscn CanvasLayer UI root

# Add equipment panel to UI
add_scene res://scenes/s08-equipment/test_equipment.tscn EquipmentUI UI res://scenes/s08-equipment/equipment_panel.tscn

# Add instructions
add_node res://scenes/s08-equipment/test_equipment.tscn Label Instructions UI
add_node res://scenes/s08-equipment/test_equipment.tscn VBoxContainer TestControls UI

# Add test buttons
add_node res://scenes/s08-equipment/test_equipment.tscn Button EquipHelmet TestControls
add_node res://scenes/s08-equipment/test_equipment.tscn Button EquipArmor TestControls
add_node res://scenes/s08-equipment/test_equipment.tscn Button EquipBoots TestControls
add_node res://scenes/s08-equipment/test_equipment.tscn Button EquipAccessory TestControls
add_node res://scenes/s08-equipment/test_equipment.tscn Button UnequipAll TestControls
add_node res://scenes/s08-equipment/test_equipment.tscn Button ShowStats TestControls

# Configure test scene
update_property res://scenes/s08-equipment/test_equipment.tscn Player position Vector2(400,300)

update_property res://scenes/s08-equipment/test_equipment.tscn Instructions text "Equipment System Test - Use buttons to equip items"
update_property res://scenes/s08-equipment/test_equipment.tscn Instructions position Vector2(10,10)

update_property res://scenes/s08-equipment/test_equipment.tscn TestControls position Vector2(10,50)

update_property res://scenes/s08-equipment/test_equipment.tscn EquipHelmet text "Equip Iron Helmet"
update_property res://scenes/s08-equipment/test_equipment.tscn EquipArmor text "Equip Chainmail"
update_property res://scenes/s08-equipment/test_equipment.tscn EquipBoots text "Equip Leather Boots"
update_property res://scenes/s08-equipment/test_equipment.tscn EquipAccessory text "Equip Ring of Strength"
update_property res://scenes/s08-equipment/test_equipment.tscn UnequipAll text "Unequip All"
update_property res://scenes/s08-equipment/test_equipment.tscn ShowStats text "Print Equipment Stats"

update_property res://scenes/s08-equipment/test_equipment.tscn EquipmentUI offset_left 600
update_property res://scenes/s08-equipment/test_equipment.tscn EquipmentUI offset_top 50
```

### Step 5: Create Test Script for Test Scene

**Note:** Create a GDScript file for the test scene to wire up the test buttons:

File: `src/systems/s08-equipment/test_equipment_scene.gd`

```gdscript
extends Node2D

@onready var player = $Player
@onready var equipment_manager: EquipmentManager = $Player/EquipmentManager

func _ready():
	# Connect test buttons
	$UI/TestControls/EquipHelmet.pressed.connect(_on_equip_helmet)
	$UI/TestControls/EquipArmor.pressed.connect(_on_equip_armor)
	$UI/TestControls/EquipBoots.pressed.connect(_on_equip_boots)
	$UI/TestControls/EquipAccessory.pressed.connect(_on_equip_accessory)
	$UI/TestControls/UnequipAll.pressed.connect(_on_unequip_all)
	$UI/TestControls/ShowStats.pressed.connect(_on_show_stats)

	print("Test Equipment Scene: Ready")

func _on_equip_helmet():
	if equipment_manager.equip_item_by_id("helmet", "iron_helmet"):
		print("Equipped Iron Helmet")
	else:
		print("Failed to equip helmet")

func _on_equip_armor():
	if equipment_manager.equip_item_by_id("torso", "chainmail"):
		print("Equipped Chainmail")
	else:
		print("Failed to equip armor")

func _on_equip_boots():
	if equipment_manager.equip_item_by_id("boots", "leather_boots"):
		print("Equipped Leather Boots")
	else:
		print("Failed to equip boots")

func _on_equip_accessory():
	if equipment_manager.equip_item_by_id("accessories", "ring_of_strength"):
		print("Equipped Ring of Strength")
	else:
		print("Failed to equip accessory")

func _on_unequip_all():
	equipment_manager.unequip_item("helmet")
	equipment_manager.unequip_item("torso")
	equipment_manager.unequip_item("boots")

	# Unequip all accessories
	var accessory_count = equipment_manager.get_accessory_count()
	for i in range(accessory_count - 1, -1, -1):
		equipment_manager.unequip_accessory(i)

	print("All equipment unequipped")

func _on_show_stats():
	equipment_manager.print_equipment()
```

Then attach this script:

```bash
attach_script res://scenes/s08-equipment/test_equipment.tscn root res://src/systems/s08-equipment/test_equipment_scene.gd
```

---

## Node Hierarchies

### Equipment Panel Structure
```
Panel (EquipmentPanel)
└── VBoxContainer (MainLayout)
    ├── Label (Title) - "Equipment"
    ├── VBoxContainer (EquipmentSlots)
    │   ├── HBoxContainer (WeaponSlotRow)
    │   │   ├── Label (WeaponLabel) - "Weapon:"
    │   │   ├── PanelContainer (WeaponSlot)
    │   │   │   └── TextureRect (WeaponIcon)
    │   │   └── Label (WeaponName)
    │   ├── HBoxContainer (HelmetSlotRow)
    │   │   ├── Label (HelmetLabel) - "Helmet:"
    │   │   ├── PanelContainer (HelmetSlot)
    │   │   │   └── TextureRect (HelmetIcon)
    │   │   └── Label (HelmetName)
    │   ├── HBoxContainer (TorsoSlotRow)
    │   │   └── [Same structure as above]
    │   └── HBoxContainer (BootsSlotRow)
    │       └── [Same structure as above]
    ├── Label (AccessoriesTitle) - "Accessories (Max 3)"
    ├── HBoxContainer (AccessorySlots)
    │   ├── PanelContainer (Accessory1Slot)
    │   │   └── TextureRect (Accessory1Icon)
    │   ├── PanelContainer (Accessory2Slot)
    │   │   └── TextureRect (Accessory2Icon)
    │   └── PanelContainer (Accessory3Slot)
    │       └── TextureRect (Accessory3Icon)
    └── VBoxContainer (StatsDisplay)
        ├── Label (StatsTitle) - "Total Stats Bonuses"
        ├── Label (StatDefense) - "Defense: +0"
        ├── Label (StatMaxHP) - "Max HP: +0"
        ├── Label (StatSpeed) - "Speed: +0"
        ├── Label (StatAttack) - "Attack: +0"
        ├── Label (StatMaxMP) - "Max MP: +0"
        └── Label (TotalWeight) - "Weight: 0.0 kg"
```

### Test Scene Structure
```
Node2D (root)
├── Player (instance of res://player/player.tscn)
│   └── EquipmentManager (EquipmentManager node with script)
└── CanvasLayer (UI)
    ├── EquipmentPanel (instance of equipment_panel.tscn)
    ├── Label (Instructions)
    └── VBoxContainer (TestControls)
        ├── Button (EquipHelmet)
        ├── Button (EquipArmor)
        ├── Button (EquipBoots)
        ├── Button (EquipAccessory)
        ├── Button (UnequipAll)
        └── Button (ShowStats)
```

---

## Integration Notes

### How to Use EquipmentManager

**From Player or Other Scripts:**

```gdscript
# Get equipment manager reference
var equipment_manager = $EquipmentManager  # If child of current node
# or
var equipment_manager = player.get_node("EquipmentManager")

# Equip item by ID
equipment_manager.equip_item_by_id("helmet", "iron_helmet")

# Equip item by data dictionary
var item_data = {
	"id": "iron_helmet",
	"name": "Iron Helmet",
	"slot": "helmet",
	# ... rest of properties
}
equipment_manager.equip_item("helmet", item_data)

# Unequip item
equipment_manager.unequip_item("helmet")

# Get total stat bonuses
var stats = equipment_manager.get_total_stat_bonuses()
print("Defense: ", stats["defense"])

# Check if slot is empty
if equipment_manager.is_slot_empty("weapon"):
	print("No weapon equipped")

# Connect to signals
equipment_manager.item_equipped.connect(_on_item_equipped)
equipment_manager.stats_changed.connect(_on_stats_changed)
```

### Integration with Combat (S04)

When equipment changes, apply stat bonuses to player combat stats:

```gdscript
func _on_stats_changed(new_stats: Dictionary):
	# Apply defense bonus
	player.defense += new_stats["defense"]

	# Apply HP bonus
	player.max_hp += new_stats["max_hp"]

	# Apply attack bonus
	player.attack += new_stats["attack"]

	# Apply speed modifier
	player.speed += new_stats["speed"]
```

### Integration with Save/Load (S06)

The EquipmentManager already has `save_state()` and `load_state()` methods:

```gdscript
# In SaveManager
func save_game():
	var save_data = {}

	# Save equipment state
	var equipment_manager = player.get_node("EquipmentManager")
	save_data["equipment"] = equipment_manager.save_state()

	# ... save other data

func load_game(save_data: Dictionary):
	# Load equipment state
	if save_data.has("equipment"):
		var equipment_manager = player.get_node("EquipmentManager")
		equipment_manager.load_state(save_data["equipment"])
```

### Integration with Inventory (S05)

Equipment items can be moved between inventory and equipment slots:

```gdscript
# Equip item from inventory
func equip_from_inventory(item_id: String, slot: String):
	# Remove from inventory
	var inventory = get_node("/root/InventoryManager")
	# ... get item from inventory

	# Equip it
	var equipment_manager = $EquipmentManager
	equipment_manager.equip_item_by_id(slot, item_id)

# Unequip to inventory
func unequip_to_inventory(slot: String):
	var equipment_manager = $EquipmentManager
	var item_data = equipment_manager.get_equipped_item(slot)

	if not item_data.is_empty():
		equipment_manager.unequip_item(slot)

		# Add to inventory
		var inventory = get_node("/root/InventoryManager")
		inventory.add_item_by_id(item_data["id"])
```

---

## Testing Checklist for Tier 2

**Before marking complete, Tier 2 agent MUST verify:**

- [ ] EquipmentManager added to Player scene as child node
- [ ] Equipment panel scene created with all UI elements
- [ ] Test scene runs without errors: `play_scene("res://scenes/s08-equipment/test_equipment.tscn")`
- [ ] Equipping helmet applies stat bonuses (check console output)
- [ ] Equipping torso armor applies stat bonuses
- [ ] Equipping boots applies stat bonuses
- [ ] Equipping accessories works (max 3)
- [ ] Unequipping items removes stat bonuses
- [ ] Stats display updates when equipment changes
- [ ] Multiple accessories can be equipped (test equipping 3, then trying a 4th)
- [ ] Slot validation prevents wrong item types (try equipping helmet in boots slot)
- [ ] Weight calculation works correctly
- [ ] Resistance bonuses are calculated
- [ ] Save/load methods work (test save_state() and load_state())
- [ ] Signals emit correctly (item_equipped, item_unequipped, stats_changed)
- [ ] No errors in Godot console: `get_godot_errors`
- [ ] Performance acceptable (no frame drops)

**Expected Results:**
- Equipment manager successfully manages 5 equipment slots
- Stat bonuses apply correctly when items are equipped
- Accessories limited to 3 maximum
- All 23 equipment items loadable from JSON
- Integration tests pass

---

## Gotchas & Known Issues

**GDScript 4.5 Specific:**
- Equipment data uses Dictionary type - ensure proper type casting
- Signals use typed parameters (e.g., `signal item_equipped(slot: String, item_data: Dictionary)`)
- Arrays must be typed: `var accessories: Array = []`

**System-Specific:**
- Equipment database must be loaded before equipping items by ID
- Accessories are stored in an array, not individual slots
- Stat bonuses are additive - negative bonuses (e.g., speed penalty) are supported
- Weight affects movement speed (future integration with S03)

**Integration Warnings:**
- S05 Inventory integration requires drag-drop UI (to be implemented)
- S07 Weapons system not yet implemented - weapon slot uses generic item data
- Visual equipment sprites are optional (sprite_path can be empty)
- Equipment must be unequipped before being removed from inventory

**Drag-Drop UI (Future Work):**
The current implementation focuses on the data layer. Drag-drop UI between inventory and equipment panels will be implemented using Godot's built-in drag-drop system:

- Override `_get_drag_data()` on equipment slots
- Override `_can_drop_data()` to validate slot compatibility
- Override `_drop_data()` to handle equip/unequip

---

## Research References

**Tier 1 Research Summary:**
- Godot 4.5 drag-drop tutorial: https://dev.to/pdeveloper/godot-4x-drag-and-drop-5g13
- Equipment system patterns: https://medium.com/@minoqi/modular-stat-attribute-system-tutorial-for-godot-4-0bac1c5062ce
- Inventory integration: https://github.com/alfredbaudisch/GodotDynamicInventorySystem
- GLoot plugin (S05): Used for inventory, equipment uses separate system
- Stat modifier patterns: https://theliquidfire.com/2024/10/10/godot-tactics-rpg-09-stats/

**Full research notes:** `research/s08-equipment-research.md`

---

## Verification Evidence Required

**Tier 2 must provide:**
1. Screenshot of test scene running (`get_editor_screenshot()`)
2. Error log output (`get_godot_errors()`) - should be empty
3. Console output showing stat calculations
4. Evidence of all 5 equipment slots working

**Save to:** `evidence/S08-tier2-verification/`

---

## Completion Criteria

**System S08 is complete when:**
- ✅ EquipmentManager integrated with Player (S03)
- ✅ All 5 equipment slots functional (weapon, helmet, torso, boots, accessories)
- ✅ Stat bonus calculation works correctly
- ✅ Accessories limited to 3 max
- ✅ Equipment database loaded from JSON (23 items)
- ✅ Save/load methods implemented
- ✅ Test scene runs without errors
- ✅ All signals emit correctly
- ✅ Integration points documented for S04, S05, S06, S09, S25
- ✅ Quality gates pass
- ✅ Checkpoint documentation complete

**Next Steps:**
- S09 (Dodge/Block) can use equipment stats for dodge/block effectiveness
- S25 (Crafting) can enhance equipment
- Job 2 Complete - All foundation systems (S01-S08) ready

---

**HANDOFF STATUS: READY FOR TIER 2**
**Estimated Tier 2 Time:** 3-4 hours (scene config + UI + testing)
**Priority:** MEDIUM (completes Job 2 foundation layer)

---

*Generated by: Claude Code Web Agent*
*Date: 2025-11-18*
*Branch: claude/implement-equipment-system-01FjiP8ozw4kRxdDR75qgWrL*
*Prompt: 010-s08-equipment-system.md*
