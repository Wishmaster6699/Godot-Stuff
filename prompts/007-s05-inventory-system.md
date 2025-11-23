<objective>
Implement Basic Inventory System (S05) - item pickup/drop/store/display using GLoot plugin. Supports capacity management and visual UI. Foundation for equipment, cooking, and crafting.

DEPENDS ON: S03 (Player) for interaction system
CAN RUN IN PARALLEL WITH: S04 (Combat) - no direct dependency
</objective>

<context>
The Inventory System uses the GLoot plugin for item management. It handles:
- Picking up items from the world
- Storing items in grid-based inventory
- Dropping items back into world
- Visual UI representation
- Capacity management (30 slots)

Will be extended by:
- **S06**: Save/Load (serialization)
- **S08**: Equipment (equippable items)
- **S24**: Cooking (ingredients)
- **S25**: Crafting (materials)

Reference:
@rhythm-rpg-implementation-guide.md (lines 586-719 for S05 specification)
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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S05")`
- [ ] Quality gates: `check_quality_gates("S05")`
- [ ] Checkpoint validation: `validate_checkpoint("S05")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S05", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<file_isolation>

## 🚨 FILE ISOLATION RULES - PREVENT MERGE CONFLICTS

**System ID:** S05 | **System Name:** Inventory

**✅ YOU MAY MODIFY:**
```
src/systems/s05-inventory/
scenes/s05-inventory/
checkpoints/s05-inventory-checkpoint.md
research/s05-inventory-research.md
HANDOFF-S05-INVENTORY.md
```

**❌ YOU MUST NOT MODIFY:** Other systems' directories, `src/core/`, `project.godot`

**See `GIT-WORKFLOW.md` for complete file isolation rules.**

</file_isolation>

<requirements>

## Web Research First
- "GLoot plugin Godot 4.5"
- "Godot 4.5 inventory system best practices"
- Visit: https://github.com/peter-kish/gloot

## Implementation Tasks

### 1. Install GLoot Plugin
- Install via AssetLib or GitHub clone
- Enable in Project Settings → Plugins
- Verify plugin loads

### 2. Inventory Script
Create `res://inventory/inventory.gd`:
- Uses GLoot's InventoryGrid resource
- Methods: `add_item(item)`, `remove_item(item)`, `has_item(item_id)`, `get_item_count(item_id)`
- Capacity: 30 slots (6x5 grid)
- Emit signals: `item_added(item)`, `item_removed(item)`, `inventory_full`

### 3. Item Definitions
Create `res://data/items.json`:
```json
{
  "items": [
    {
      "id": "health_potion",
      "name": "Health Potion",
      "description": "Restores 50 HP",
      "type": "consumable",
      "icon_path": "res://assets/icons/health_potion.png",
      "stack_size": 99,
      "effects": { "heal": 50 }
    },
    {
      "id": "iron_sword",
      "name": "Iron Sword",
      "type": "weapon",
      "icon_path": "res://assets/icons/iron_sword.png",
      "stack_size": 1,
      "stats": { "damage": 15, "speed": 1.0 }
    }
  ]
}
```

### 4. World Item Pickups
Create `res://items/item_pickup.tscn`:
- Area2D with sprite
- Connects to Player InteractionArea (from S03)
- On interact: add to inventory, remove from world

### 5. Inventory UI
Create `res://ui/inventory_ui.tscn`:
- GridContainer (6x5 = 30 slots)
- Displays item icons
- Updates in real-time
- Click to select/use item

### 6. Test Scene
Create `res://tests/test_inventory.tscn`:
- Player with inventory
- 5+ different item types to pickup
- Visual feedback

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://inventory/inventory.gd` - Inventory manager using GLoot plugin
   - Complete implementations with full logic
   - Type hints, documentation, error handling
   - Integration with Player (S03) InteractionArea

2. **Create all JSON data files** using the Write tool
   - `res://data/items.json` - Item definitions with types, stats, icons
   - Valid JSON format with all required fields

3. **Create HANDOFF-S05.md** documenting:
   - Scene structures needed (inventory UI, item pickup, test scene)
   - MCP agent tasks (use GDAI tools)
   - Node hierarchies and property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- `res://inventory/inventory.gd` - Complete Inventory implementation
- `res://data/items.json` - Item database
- `HANDOFF-S05.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S05.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create inventory_ui.tscn, item_pickup.tscn, test_inventory.tscn
   - `add_node` - Build node hierarchies (GridContainer, Area2D, Sprite2D)
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set UI positions, grid layouts, collision shapes
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S05.md` with this structure:

```markdown
# HANDOFF: S05 - Inventory System

## Files Created by Claude Code Web

### GDScript Files
- `res://inventory/inventory.gd` - Inventory manager using GLoot plugin with add/remove/check methods

### Data Files
- `res://data/items.json` - Item definitions (consumables, weapons, materials) with icons and stats

## MCP Agent Tasks

### 1. Create Inventory UI Scene

```bash
# Create inventory UI scene
create_scene res://ui/inventory_ui.tscn
add_node res://ui/inventory_ui.tscn Panel InventoryPanel root
add_node res://ui/inventory_ui.tscn VBoxContainer Layout InventoryPanel
add_node res://ui/inventory_ui.tscn Label Title Layout
add_node res://ui/inventory_ui.tscn GridContainer ItemGrid Layout

# Configure grid for 30 slots (6x5)
update_property res://ui/inventory_ui.tscn ItemGrid columns 6
update_property res://ui/inventory_ui.tscn ItemGrid custom_minimum_size "Vector2(384, 320)"

# Add inventory slots
add_node res://ui/inventory_ui.tscn PanelContainer Slot1 ItemGrid
add_node res://ui/inventory_ui.tscn TextureRect Icon1 Slot1
add_node res://ui/inventory_ui.tscn Label Count1 Slot1

add_node res://ui/inventory_ui.tscn PanelContainer Slot2 ItemGrid
add_node res://ui/inventory_ui.tscn TextureRect Icon2 Slot2
add_node res://ui/inventory_ui.tscn Label Count2 Slot2

# Repeat for remaining slots (3-30) following the same pattern
# Each slot needs: PanelContainer -> TextureRect (icon) + Label (count)

# Configure panel
update_property res://ui/inventory_ui.tscn InventoryPanel custom_minimum_size "Vector2(400, 400)"
update_property res://ui/inventory_ui.tscn InventoryPanel anchor_preset 8
update_property res://ui/inventory_ui.tscn Title text "Inventory (30 slots)"
update_property res://ui/inventory_ui.tscn Title horizontal_alignment 1
```

### 2. Create Item Pickup Scene

```bash
# Create item pickup scene
create_scene res://items/item_pickup.tscn
add_node res://items/item_pickup.tscn Area2D ItemPickup root
add_node res://items/item_pickup.tscn Sprite2D ItemSprite ItemPickup
add_node res://items/item_pickup.tscn CollisionShape2D PickupCollision ItemPickup

# Configure pickup
update_property res://items/item_pickup.tscn PickupCollision shape "CircleShape2D(radius=16)"
update_property res://items/item_pickup.tscn ItemSprite modulate "Color(1, 1, 0, 1)"
```

### 3. Create Test Scene

```bash
create_scene res://tests/test_inventory.tscn
add_node res://tests/test_inventory.tscn Node2D TestInventory root
add_node res://tests/test_inventory.tscn CharacterBody2D Player TestInventory
add_node res://tests/test_inventory.tscn Sprite2D PlayerSprite Player
add_node res://tests/test_inventory.tscn CollisionShape2D PlayerCollision Player
add_node res://tests/test_inventory.tscn Area2D InteractionArea Player
add_node res://tests/test_inventory.tscn CollisionShape2D InteractionCollision InteractionArea

# Add inventory UI to test scene
add_node res://tests/test_inventory.tscn CanvasLayer UI TestInventory
add_node res://tests/test_inventory.tscn Control InventoryUI UI res://ui/inventory_ui.tscn

# Add test items to pickup
add_node res://tests/test_inventory.tscn Node2D TestItems TestInventory
add_node res://tests/test_inventory.tscn Area2D HealthPotion TestItems res://items/item_pickup.tscn
add_node res://tests/test_inventory.tscn Area2D IronSword TestItems res://items/item_pickup.tscn
add_node res://tests/test_inventory.tscn Area2D CopperOre TestItems res://items/item_pickup.tscn
add_node res://tests/test_inventory.tscn Area2D ManaPotion TestItems res://items/item_pickup.tscn
add_node res://tests/test_inventory.tscn Area2D IronOre TestItems res://items/item_pickup.tscn

# Configure test scene
update_property res://tests/test_inventory.tscn Player position "Vector2(400, 300)"
update_property res://tests/test_inventory.tscn PlayerCollision shape "CircleShape2D(radius=16)"
update_property res://tests/test_inventory.tscn InteractionCollision shape "CircleShape2D(radius=64)"
update_property res://tests/test_inventory.tscn HealthPotion position "Vector2(300, 300)"
update_property res://tests/test_inventory.tscn IronSword position "Vector2(500, 300)"
update_property res://tests/test_inventory.tscn CopperOre position "Vector2(350, 250)"
update_property res://tests/test_inventory.tscn ManaPotion position "Vector2(450, 250)"
update_property res://tests/test_inventory.tscn IronOre position "Vector2(400, 350)"

# Add test instructions
add_node res://tests/test_inventory.tscn Label Instructions UI
update_property res://tests/test_inventory.tscn Instructions text "Walk near items to pick up. Press I to toggle inventory. Test capacity (30 slots max)."
update_property res://tests/test_inventory.tscn Instructions position "Vector2(10, 10)"
```

## Testing Checklist

Use Godot MCP tools to test:

```bash
# Run test scene
play_scene res://tests/test_inventory.tscn

# Check for errors
get_godot_errors
```

### Verify:
- [ ] GLoot plugin installed and enabled in Project Settings → Plugins
- [ ] Player can pick up items by walking near them (InteractionArea detection)
- [ ] Items appear in inventory UI with correct icons
- [ ] Item count displayed for stackable items
- [ ] Inventory prevents overflow when full (30 slots)
- [ ] Items stack correctly (up to stack_size limit from items.json)
- [ ] Different item types handled (consumable, weapon, material)
- [ ] UI updates in real-time when items added/removed
- [ ] Player can drop items back into world (if implemented)

### Integration Points:
- **S03 (Player)**: Uses Player InteractionArea for pickup detection
- **GLoot Plugin**: Must be installed and enabled before testing
- Ready for **S06 (Save/Load)** to serialize inventory
- Ready for **S08 (Equipment)** to handle equippable items
- Ready for **S24 (Cooking)** for ingredients
- Ready for **S25 (Crafting)** for materials

## Completion

Update COORDINATION-DASHBOARD.md:
- Mark S05 as complete
- Release any locked resources
- Unblock S06, S08, S24, S25
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S05.md, verify:

### Code Quality
- [ ] inventory.gd created with complete implementation (no TODOs or placeholders)
- [ ] items.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented where needed
- [ ] Integration patterns documented (signals, method calls)

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (inventory/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S05.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] Inventory manager with add_item(), remove_item(), has_item() methods
- [ ] Item database with multiple item types (consumable, weapon, material)
- [ ] Stack size logic implemented
- [ ] Capacity management (30 slots) implemented
- [ ] GLoot integration patterns documented
- [ ] All item definitions have required fields (id, name, type, icon_path, stack_size)

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] All scenes created using `create_scene`
- [ ] All nodes added using `add_node` in correct hierarchy
- [ ] All scripts attached using `attach_script`
- [ ] All properties set using `update_property`
- [ ] GLoot plugin installed and enabled

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S05")`
- [ ] Quality gates passed: `check_quality_gates("S05")`
- [ ] Checkpoint validated: `validate_checkpoint("S05")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] GLoot plugin installed and working
- [ ] Player can pick up items from world
- [ ] Items appear in inventory UI with correct icons
- [ ] Items stack correctly (up to stack_size limit)
- [ ] Player can drop items back into world
- [ ] Inventory prevents overflow when full (30 slots)
- [ ] UI updates in real-time when items added/removed
- [ ] Different item types handled (consumable, weapon, material)

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ inventory.gd complete with GLoot integration
- ✅ items.json complete with multiple item types and definitions
- ✅ HANDOFF-S05.md provides clear MCP agent instructions
- ✅ All inventory operations implemented (add, remove, check, count)
- ✅ Integration patterns documented for Player (S03)

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Inventory UI configured correctly in Godot editor
- ✅ Item pickup works from world
- ✅ Items display with icons in UI
- ✅ Stacking works correctly
- ✅ Capacity management prevents overflow
- ✅ Drop items back to world works
- ✅ All verification criteria pass
- ✅ System ready for dependent systems (S06, S08, S24, S25)

</success_criteria>

<memory_checkpoint_format>
```
System S05 (Inventory) Complete

FILES CREATED:
- res://inventory/inventory.gd (Inventory manager using GLoot)
- res://data/items.json (Item definitions)
- res://items/item_pickup.tscn (World item pickup scene)
- res://ui/inventory_ui.tscn (Inventory UI 6x5 grid)
- res://tests/test_inventory.tscn (Test scene)

INVENTORY CONFIG:
- Max slots: 30 (6x5 grid)
- Item types: consumable, weapon, material, key, quest
- Stack sizes: Per item definition

ITEM TYPES:
- Consumable (health_potion, etc.)
- Weapon (iron_sword, etc.)
- Material (copper_ore, etc.)
- Key items
- Quest items

SIGNALS EXPOSED:
- item_added(item)
- item_removed(item)
- inventory_full

INTEGRATION:
- Uses Player (S03) InteractionArea for pickup
- Ready for S06 (Save/Load) to serialize inventory
- Ready for S08 (Equipment) to handle equippable items
- Ready for S24 (Cooking) for ingredients
- Ready for S25 (Crafting) for materials

STATUS: Ready for S06, S08, S24, S25
```
</memory_checkpoint_format>
