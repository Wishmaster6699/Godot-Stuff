# HANDOFF: S05 - Inventory System
**From:** Tier 1 (Claude Code Web)
**To:** Tier 2 (Godot MCP Agent)
**Date:** 2025-11-18
**Status:** READY FOR TIER 2
**System:** S05 - Inventory System using GLoot plugin

---

## System Overview

**Purpose:** Inventory system for storing, managing, and displaying items using the GLoot plugin. Supports grid-based inventory (6x5 = 30 slots), item stacking, capacity management, and integration with Player interaction system.

**Type:** Component System (attached to Player) + UI Layer

**Dependencies:**
- **S03 (Player):** Uses PlayerController's InteractionArea for item pickup detection
- **GLoot Plugin:** MUST be installed from Asset Library before proceeding

**Blocks:** S06 (Save/Load), S08 (Equipment), S24 (Cooking), S25 (Crafting)

---

## Files Created by Tier 1

### GDScript Files
- ✅ `src/systems/s05-inventory/inventory_manager.gd` - Wrapper around GLoot's Inventory class
- ✅ `src/systems/s05-inventory/item_pickup.gd` - Area2D for world item pickups
- ✅ `src/systems/s05-inventory/inventory_ui.gd` - UI wrapper for GLoot's CtrlInventoryGrid
- ✅ `src/systems/s05-inventory/test_inventory.gd` - Test scene controller

### JSON Data Files
- ✅ `data/items.json` - Item protoset with 20 item types (consumables, weapons, materials, etc.)
- ✅ `data/inventory_config.json` - Inventory configuration (grid size, capacity, UI settings)

### Research Files
- ✅ `research/s05-inventory-research.md` - Complete research findings on GLoot plugin

**All files validated:** Syntax ✓ | Type hints ✓ | Documentation ✓ | Godot 4.5 compatible ✓

---

## 🚨 CRITICAL: Install GLoot Plugin FIRST

**BEFORE creating any scenes, you MUST install the GLoot plugin:**

### Step 1: Open Godot Editor
```bash
# Open the project in Godot 4.5
godot --editor vibe-code-game/project.godot
```

### Step 2: Install GLoot via AssetLib
1. Click AssetLib tab at top of editor
2. Search for "GLoot"
3. Click on "GLoot (Universal Inventory System)"
4. Click "Download" then "Install"
5. Confirm installation

### Step 3: Enable Plugin
1. Go to Project → Project Settings → Plugins
2. Find "GLoot" in the list
3. Check the "Enable" checkbox
4. Click "Close"

### Step 4: Verify Installation
```python
# Use Godot MCP to verify
execute_editor_script("print('Testing GLoot:', ClassDB.class_exists('Inventory'))")
# Should output: Testing GLoot: True
```

**⚠️ DO NOT PROCEED until GLoot is installed and enabled!**

---

## Godot MCP Commands for Tier 2

### Phase 1: Create Item Pickup Scene Template

This scene is a template for spawnable world items.

```bash
# Create item pickup scene with Area2D root
create_scene res://scenes/s05-inventory/item_pickup.tscn Area2D

# Add sprite for visual representation
add_node res://scenes/s05-inventory/item_pickup.tscn Sprite2D ItemSprite Area2D

# Add collision shape for pickup detection
add_node res://scenes/s05-inventory/item_pickup.tscn CollisionShape2D PickupCollision Area2D

# Add label to show item name
add_node res://scenes/s05-inventory/item_pickup.tscn Label ItemLabel Area2D

# Attach item pickup script
attach_script res://scenes/s05-inventory/item_pickup.tscn Area2D res://src/systems/s05-inventory/item_pickup.gd

# Configure sprite
update_property res://scenes/s05-inventory/item_pickup.tscn ItemSprite modulate "Color(1, 0.8, 0.2, 1)"
update_property res://scenes/s05-inventory/item_pickup.tscn ItemSprite scale "Vector2(0.5, 0.5)"

# Configure collision (circular area for pickup)
update_property res://scenes/s05-inventory/item_pickup.tscn PickupCollision shape "CircleShape2D"

# Set collision shape radius (using execute_editor_script)
execute_editor_script("var scene = load('res://scenes/s05-inventory/item_pickup.tscn').instantiate(); var shape = CircleShape2D.new(); shape.radius = 32.0; scene.get_node('PickupCollision').shape = shape; print('Pickup collision shape configured')")

# Configure label
update_property res://scenes/s05-inventory/item_pickup.tscn ItemLabel position "Vector2(0, -40)"
update_property res://scenes/s05-inventory/item_pickup.tscn ItemLabel horizontal_alignment 1
update_property res://scenes/s05-inventory/item_pickup.tscn ItemLabel vertical_alignment 1
update_property res://scenes/s05-inventory/item_pickup.tscn ItemLabel text "Item"
update_property res://scenes/s05-inventory/item_pickup.tscn ItemLabel modulate "Color(1, 1, 1, 0.9)"
```

---

### Phase 2: Create Inventory UI Scene

This scene displays the inventory using GLoot's CtrlInventoryGrid.

```bash
# Create inventory UI with Control root
create_scene res://scenes/s05-inventory/inventory_ui.tscn Control

# Add Panel container
add_node res://scenes/s05-inventory/inventory_ui.tscn Panel MainPanel Control

# Add VBoxContainer for layout
add_node res://scenes/s05-inventory/inventory_ui.tscn VBoxContainer Layout MainPanel

# Add title label
add_node res://scenes/s05-inventory/inventory_ui.tscn Label TitleLabel Layout

# Add capacity label
add_node res://scenes/s05-inventory/inventory_ui.tscn Label CapacityLabel Layout

# Add GLoot's CtrlInventoryGrid (CRITICAL - requires GLoot plugin)
add_node res://scenes/s05-inventory/inventory_ui.tscn CtrlInventoryGrid CtrlInventoryGrid Layout

# Add close button
add_node res://scenes/s05-inventory/inventory_ui.tscn Button CloseButton Layout

# Attach inventory UI script
attach_script res://scenes/s05-inventory/inventory_ui.tscn Control res://src/systems/s05-inventory/inventory_ui.gd

# Configure main panel
update_property res://scenes/s05-inventory/inventory_ui.tscn MainPanel custom_minimum_size "Vector2(500, 600)"
update_property res://scenes/s05-inventory/inventory_ui.tscn MainPanel position "Vector2(400, 100)"

# Configure layout
update_property res://scenes/s05-inventory/inventory_ui.tscn Layout custom_minimum_size "Vector2(480, 580)"

# Configure title
update_property res://scenes/s05-inventory/inventory_ui.tscn TitleLabel text "Inventory (0/30)"
update_property res://scenes/s05-inventory/inventory_ui.tscn TitleLabel horizontal_alignment 1
update_property res://scenes/s05-inventory/inventory_ui.tscn TitleLabel custom_minimum_size "Vector2(0, 40)"

# Configure capacity label
update_property res://scenes/s05-inventory/inventory_ui.tscn CapacityLabel text "Capacity: 0/30 (0%)"
update_property res://scenes/s05-inventory/inventory_ui.tscn CapacityLabel horizontal_alignment 1
update_property res://scenes/s05-inventory/inventory_ui.tscn CapacityLabel custom_minimum_size "Vector2(0, 30)"

# Configure CtrlInventoryGrid
update_property res://scenes/s05-inventory/inventory_ui.tscn CtrlInventoryGrid custom_minimum_size "Vector2(480, 400)"

# Configure close button
update_property res://scenes/s05-inventory/inventory_ui.tscn CloseButton text "Close (ESC)"
update_property res://scenes/s05-inventory/inventory_ui.tscn CloseButton custom_minimum_size "Vector2(0, 40)"
```

---

### Phase 3: Setup Player with Inventory System

Modify the existing Player scene to add inventory components.

```bash
# Open existing player scene (from S03)
open_scene res://scenes/s03-player/player.tscn

# Add InventoryManager as child of Player
add_node res://scenes/s03-player/player.tscn Node InventoryManager PlayerController

# Attach InventoryManager script
attach_script res://scenes/s03-player/player.tscn InventoryManager res://src/systems/s05-inventory/inventory_manager.gd

# Note: InteractionArea already exists in Player from S03
# No changes needed to interaction system
```

---

### Phase 4: Create Test Scene

Comprehensive test scene with player, inventory UI, and test items.

```bash
# Create test scene with Node2D root
create_scene res://scenes/s05-inventory/test_inventory.tscn Node2D

# Add the modified Player scene (with InventoryManager)
add_scene res://scenes/s05-inventory/test_inventory.tscn Player Node2D res://scenes/s03-player/player.tscn

# Add Camera2D to follow player
add_node res://scenes/s05-inventory/test_inventory.tscn Camera2D Camera Player

# Add CanvasLayer for UI
add_node res://scenes/s05-inventory/test_inventory.tscn CanvasLayer UI Node2D

# Add InventoryUI to canvas layer
add_scene res://scenes/s05-inventory/test_inventory.tscn InventoryUI UI res://scenes/s05-inventory/inventory_ui.tscn

# Add instructions label
add_node res://scenes/s05-inventory/test_inventory.tscn Label Instructions UI

# Add debug panel
add_node res://scenes/s05-inventory/test_inventory.tscn Panel DebugPanel UI
add_node res://scenes/s05-inventory/test_inventory.tscn Label DebugLabel DebugPanel

# Add test items container
add_node res://scenes/s05-inventory/test_inventory.tscn Node2D TestItems Node2D

# Add test item pickups (8 different items)
add_scene res://scenes/s05-inventory/test_inventory.tscn Item1_HealthPotion TestItems res://scenes/s05-inventory/item_pickup.tscn
add_scene res://scenes/s05-inventory/test_inventory.tscn Item2_ManaPotion TestItems res://scenes/s05-inventory/item_pickup.tscn
add_scene res://scenes/s05-inventory/test_inventory.tscn Item3_IronSword TestItems res://scenes/s05-inventory/item_pickup.tscn
add_scene res://scenes/s05-inventory/test_inventory.tscn Item4_CopperOre TestItems res://scenes/s05-inventory/item_pickup.tscn
add_scene res://scenes/s05-inventory/test_inventory.tscn Item5_IronOre TestItems res://scenes/s05-inventory/item_pickup.tscn
add_scene res://scenes/s05-inventory/test_inventory.tscn Item6_Bread TestItems res://scenes/s05-inventory/item_pickup.tscn
add_scene res://scenes/s05-inventory/test_inventory.tscn Item7_HerbGreen TestItems res://scenes/s05-inventory/item_pickup.tscn
add_scene res://scenes/s05-inventory/test_inventory.tscn Item8_GoldCoin TestItems res://scenes/s05-inventory/item_pickup.tscn

# Attach test script to root
attach_script res://scenes/s05-inventory/test_inventory.tscn Node2D res://src/systems/s05-inventory/test_inventory.gd

# Configure player position
update_property res://scenes/s05-inventory/test_inventory.tscn Player position "Vector2(400, 300)"

# Configure camera
update_property res://scenes/s05-inventory/test_inventory.tscn Camera enabled true
update_property res://scenes/s05-inventory/test_inventory.tscn Camera zoom "Vector2(1.5, 1.5)"

# Configure instructions label
update_property res://scenes/s05-inventory/test_inventory.tscn Instructions position "Vector2(10, 10)"
update_property res://scenes/s05-inventory/test_inventory.tscn Instructions custom_minimum_size "Vector2(300, 200)"

# Configure debug panel
update_property res://scenes/s05-inventory/test_inventory.tscn DebugPanel position "Vector2(10, 220)"
update_property res://scenes/s05-inventory/test_inventory.tscn DebugPanel custom_minimum_size "Vector2(300, 150)"

# Configure debug label
update_property res://scenes/s05-inventory/test_inventory.tscn DebugLabel position "Vector2(10, 10)"

# Position test items around the scene
update_property res://scenes/s05-inventory/test_inventory.tscn Item1_HealthPotion position "Vector2(300, 300)"
update_property res://scenes/s05-inventory/test_inventory.tscn Item2_ManaPotion position "Vector2(500, 300)"
update_property res://scenes/s05-inventory/test_inventory.tscn Item3_IronSword position "Vector2(350, 250)"
update_property res://scenes/s05-inventory/test_inventory.tscn Item4_CopperOre position "Vector2(450, 250)"
update_property res://scenes/s05-inventory/test_inventory.tscn Item5_IronOre position "Vector2(400, 350)"
update_property res://scenes/s05-inventory/test_inventory.tscn Item6_Bread position "Vector2(300, 400)"
update_property res://scenes/s05-inventory/test_inventory.tscn Item7_HerbGreen position "Vector2(500, 400)"
update_property res://scenes/s05-inventory/test_inventory.tscn Item8_GoldCoin position "Vector2(400, 200)"

# Set item prototype IDs using execute_editor_script
execute_editor_script("
var scene = load('res://scenes/s05-inventory/test_inventory.tscn').instantiate()
scene.get_node('TestItems/Item1_HealthPotion').item_prototype_id = 'health_potion'
scene.get_node('TestItems/Item2_ManaPotion').item_prototype_id = 'mana_potion'
scene.get_node('TestItems/Item3_IronSword').item_prototype_id = 'iron_sword'
scene.get_node('TestItems/Item4_CopperOre').item_prototype_id = 'copper_ore'
scene.get_node('TestItems/Item5_IronOre').item_prototype_id = 'iron_ore'
scene.get_node('TestItems/Item6_Bread').item_prototype_id = 'bread'
scene.get_node('TestItems/Item7_HerbGreen').item_prototype_id = 'herb_green'
scene.get_node('TestItems/Item8_GoldCoin').item_prototype_id = 'gold_coin'
print('Item prototype IDs configured')
")
```

---

## Node Hierarchies

### Item Pickup Scene Structure
```
Area2D (item_pickup.tscn)
├── Sprite2D (ItemSprite) - Visual representation
├── CollisionShape2D (PickupCollision) - CircleShape2D radius=32
├── Label (ItemLabel) - Shows item name when near
└── [Script: item_pickup.gd]
```

### Inventory UI Scene Structure
```
Control (inventory_ui.tscn)
└── Panel (MainPanel)
    └── VBoxContainer (Layout)
        ├── Label (TitleLabel) - "Inventory (0/30)"
        ├── Label (CapacityLabel) - "Capacity: 0/30 (0%)"
        ├── CtrlInventoryGrid (CtrlInventoryGrid) - GLoot grid display
        ├── Button (CloseButton) - "Close (ESC)"
        └── [Script: inventory_ui.gd]
```

### Player with Inventory (Modified S03 Scene)
```
CharacterBody2D (player.tscn)
├── [Existing S03 nodes...]
├── InteractionArea (Area2D) - Already exists from S03
└── InventoryManager (Node) - NEW
    └── [Script: inventory_manager.gd]
        └── PlayerInventory (Inventory) - Created programmatically by script
            └── GridConstraint - Created programmatically
```

### Test Scene Structure
```
Node2D (test_inventory.tscn)
├── Player (CharacterBody2D) - Instance of player.tscn
│   └── Camera (Camera2D) - Follows player
├── TestItems (Node2D) - Container for test pickups
│   ├── Item1_HealthPotion (Area2D)
│   ├── Item2_ManaPotion (Area2D)
│   ├── Item3_IronSword (Area2D)
│   ├── Item4_CopperOre (Area2D)
│   ├── Item5_IronOre (Area2D)
│   ├── Item6_Bread (Area2D)
│   ├── Item7_HerbGreen (Area2D)
│   └── Item8_GoldCoin (Area2D)
├── UI (CanvasLayer)
│   ├── InventoryUI (Control) - Instance of inventory_ui.tscn
│   ├── Instructions (Label) - Test instructions
│   └── DebugPanel (Panel)
│       └── DebugLabel (Label)
└── [Script: test_inventory.gd]
```

---

## Property Configurations

### Critical Properties

**InventoryManager:**
- `grid_width`: 6
- `grid_height`: 5
- `max_slots`: 30
- Creates GLoot Inventory + GridConstraint programmatically
- Loads protoset from `res://data/items.json`

**ItemPickup:**
- `collision_layer`: 4 (Layer 3 for interactables)
- `collision_mask`: 0 (Player detects us, not vice versa)
- `item_prototype_id`: Set per instance (health_potion, iron_sword, etc.)
- `quantity`: 1 (default)
- `auto_pickup`: false (requires interaction)

**InventoryUI:**
- `toggle_key`: "ui_cancel" (ESC key)
- `start_hidden`: true
- `pause_game_when_open`: false

**CtrlInventoryGrid (GLoot):**
- `inventory`: Linked to InventoryManager's inventory node
- `field_dimensions`: Default (will be set by GLoot)
- Grid auto-configures based on GridConstraint (6x5)

---

## Integration Notes

### How to Connect Inventory to Player

The InventoryManager is added as a child node of the Player. When the player interacts with an item pickup:

1. Player's InteractionArea detects ItemPickup (Area2D)
2. Player emits `player_interacted` signal
3. ItemPickup's `interact(player)` method is called
4. ItemPickup finds InventoryManager in player node
5. ItemPickup calls `inventory_manager.add_item_by_id(item_id)`
6. InventoryManager adds item to GLoot's Inventory
7. UI updates automatically via signals

### How to Link UI to Inventory

The InventoryUI script automatically finds InventoryManager and links the CtrlInventoryGrid:

```gdscript
# This happens automatically in inventory_ui.gd _ready()
var inventory_manager = # found in player
var inventory = inventory_manager.inventory  # GLoot's Inventory node
ctrl_inventory_grid.inventory = inventory  # Link UI to data
```

### GLoot Protoset Loading

The item protoset must be converted to GLoot's format:

1. Tier 1 created `data/items.json` in protoset format
2. Tier 2 must ensure this is loaded as a Resource in Godot
3. InventoryManager loads it: `inventory.set_protoset(load("res://data/items.json"))`
4. GLoot handles item creation from prototypes

**⚠️ IMPORTANT:** If `items.json` is not recognized as a resource, you may need to:
- Create an ItemProtoset resource file manually
- Or use `execute_editor_script` to convert JSON to GLoot's protoset format

---

## Testing Checklist for Tier 2

**Before marking complete, Tier 2 agent MUST verify:**

### GLoot Plugin Installation
- [ ] GLoot plugin installed from AssetLib
- [ ] GLoot plugin enabled in Project Settings → Plugins
- [ ] `ClassDB.class_exists("Inventory")` returns true
- [ ] `ClassDB.class_exists("CtrlInventoryGrid")` returns true
- [ ] No errors in Godot editor console about missing classes

### Scene Configuration
- [ ] `item_pickup.tscn` created with all nodes and script attached
- [ ] `inventory_ui.tscn` created with CtrlInventoryGrid and script attached
- [ ] Player scene modified with InventoryManager child node
- [ ] `test_inventory.tscn` created with all test items and UI

### Functional Testing (Run test_inventory.tscn)
- [ ] Test scene runs without errors: `play_scene("res://scenes/s05-inventory/test_inventory.tscn")`
- [ ] Player can move around (WASD/arrows)
- [ ] Item pickups visible in scene (8 glowing items)
- [ ] Player can walk near items and see labels
- [ ] Player can press E/Enter to pick up items
- [ ] Items disappear from world when picked up
- [ ] Inventory UI opens/closes with ESC key
- [ ] CtrlInventoryGrid displays picked-up items
- [ ] Item stacking works (picking up multiple health potions)
- [ ] Capacity label updates (X/30 slots)
- [ ] Inventory prevents pickup when full (30/30)
- [ ] Console shows pickup messages with no errors

### Integration Testing
- [ ] InventoryManager found in Player node
- [ ] InventoryManager creates GLoot Inventory successfully
- [ ] GridConstraint applied (6x5 grid)
- [ ] Protoset loaded from items.json
- [ ] InventoryUI links to InventoryManager correctly
- [ ] Signals working (item_added, item_removed, capacity_changed)
- [ ] Player's InteractionArea detects item pickups
- [ ] ItemPickup's interact() method called on player interaction

### Quality Gates
- [ ] Integration tests pass: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S05")`
- [ ] Quality gates pass: `check_quality_gates("S05")`
- [ ] No Godot errors: `get_godot_errors()` returns empty or warnings only

### Expected Results
- **Integration Tests:** 12/12 PASS (inventory add/remove/capacity/UI)
- **Performance:** <0.5ms per frame for inventory operations
- **Quality Score:** ≥80/100 (passing threshold)
- **No Critical Errors:** Only warnings acceptable (e.g., placeholder textures)

---

## Gotchas & Known Issues

### Godot 4.5 Specific
1. **CircleShape2D Creation:** Must use `CircleShape2D.new()` and set `radius` property, not constructor
2. **Signal Connections:** Use `signal_name.connect(callable)` not `connect("signal_name", callable)`
3. **ClassDB Instantiation:** Use `ClassDB.instantiate("ClassName")` for plugin classes
4. **Node Paths:** Always use `res://` prefix, not relative paths

### GLoot Specific
1. **Plugin Must Be Enabled First:** Cannot create Inventory/CtrlInventoryGrid nodes until plugin enabled
2. **Protoset Format:** JSON must match GLoot's expected structure (see research notes)
3. **GridConstraint Size:** Use `Vector2i(6, 5)` not `Vector2(6, 5)` in GDScript
4. **UI Linking:** CtrlInventoryGrid requires `inventory` property set to GLoot's Inventory node

### System-Specific
1. **Item Pickup Detection:** Player must have InteractionArea (from S03) - DO NOT create duplicate
2. **Collision Layers:** ItemPickup uses layer 3 (bit 4), Player InteractionArea must detect layer 3
3. **Script Loading Order:** InventoryManager must load protoset AFTER Inventory node created
4. **UI Visibility:** InventoryUI starts hidden, toggle with ESC (not auto-opened)

### Integration Warnings
1. **Player Scene Modification:** Must modify existing S03 player scene, not create new one
2. **Save/Load Ready:** S06 will call `inventory_manager.serialize()` - ensure it works
3. **Equipment Ready:** S08 will filter inventory for equippable items
4. **Cooking/Crafting Ready:** S24/S25 will read ingredient items from inventory

### Asset Warnings
1. **Placeholder Textures:** Item icons don't exist yet - use colored sprites or default icons
2. **Audio Missing:** Pickup sounds referenced but not yet created
3. **Animations:** Item bobbing/spinning implemented in code, no AnimationPlayer needed

---

## Research References

**Tier 1 Research Summary:**
- GLoot GitHub: https://github.com/peter-kish/gloot
- GLoot Documentation: https://github.com/peter-kish/gloot/tree/master/docs
- Godot 4.5 Inventory Best Practices: Multiple sources researched
- Full details in: `research/s05-inventory-research.md`

---

## Verification Evidence Required

**Tier 2 must provide:**
1. Screenshot of test scene running with player and items: `get_running_scene_screenshot()`
2. Screenshot of inventory UI open showing grid: `get_editor_screenshot()`
3. Screenshot showing inventory with items: (after picking up 5+ items)
4. Console output showing no errors: `get_godot_errors()`
5. Performance profile output: `PerformanceProfiler.profile_system("S05")`
6. Integration test results: (all tests passing)

**Save evidence to:** `evidence/S05-tier2-verification/`

---

## Completion Criteria

**System S05 is complete when:**
- ✅ GLoot plugin installed and verified working
- ✅ All 4 scenes created and configured correctly
- ✅ Test scene runs without errors
- ✅ Player can pick up items (walk near + interact)
- ✅ Items appear in inventory UI
- ✅ Item stacking works for stackable items
- ✅ Capacity management prevents overflow (30 slots max)
- ✅ UI updates in real-time when items added/removed
- ✅ All integration tests pass
- ✅ Performance meets targets (<0.5ms per operation)
- ✅ Quality gates pass (score ≥80)
- ✅ Checkpoints created (markdown + Memory MCP)
- ✅ Unblocked systems notified: S06, S08, S24, S25

**Next Steps After Completion:**
- S06 (Save/Load) can serialize inventory data
- S08 (Equipment) can access equippable items from inventory
- S24 (Cooking) can use ingredient items from inventory
- S25 (Crafting) can use material items from inventory

---

**HANDOFF STATUS: READY FOR TIER 2**
**Estimated Tier 2 Time:** 3-4 hours (plugin install + scene config + testing)
**Priority:** MEDIUM (blocks 4 systems: S06, S08, S24, S25)
**Dependencies:** S03 complete ✅

---

*Generated by: Claude Code Web (Tier 1)*
*Date: 2025-11-18*
*Prompt: 007-s05-inventory-system.md*
*Research: research/s05-inventory-research.md*
