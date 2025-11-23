<objective>
Implement Full Equipment System (S08) - 5 equipment slots (weapon, helmet, torso, boots, accessories) with stat bonuses, equip/unequip mechanics, UI with drag-drop from inventory, and optional visual representation on player sprite.

DEPENDS ON: S05 (Inventory), S07 (Weapons Database)
FINAL SYSTEM OF JOB 2 - Completes foundation layer
</objective>

<context>
The Equipment System allows players to equip items that provide stat bonuses. It manages:
- 5 equipment slots: weapon, helmet, torso, boots, accessories (max 3 accessories)
- Stat bonus calculation from all equipped items
- Equip/unequip mechanics
- Equipment UI with drag-drop from inventory
- Integration with Combat (S04) for stat application
- Optional visual equipment on player sprite

Will be extended by:
- **S09**: Dodge/Block (equipment affects dodge/block effectiveness)
- **S25**: Crafting (equipment enhancement)

Reference:
@rhythm-rpg-implementation-guide.md (lines 1246-1403 for S08 specification)
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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S08")`
- [ ] Quality gates: `check_quality_gates("S08")`
- [ ] Checkpoint validation: `validate_checkpoint("S08")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S08", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<file_isolation>

## 🚨 FILE ISOLATION RULES - PREVENT MERGE CONFLICTS

**System ID:** S08 | **System Name:** Equipment

**✅ YOU MAY MODIFY:**
```
src/systems/s08-equipment/
scenes/s08-equipment/
checkpoints/s08-equipment-checkpoint.md
research/s08-equipment-research.md
HANDOFF-S08-EQUIPMENT.md
```

**❌ YOU MUST NOT MODIFY:** Other systems' directories, `src/core/`, `project.godot`

**See `GIT-WORKFLOW.md` for complete file isolation rules.**

</file_isolation>

<requirements>

## Web Research First
- "Godot 4.5 equipment system best practices"
- "Godot 4.5 drag and drop UI"
- https://docs.godotengine.org/en/4.5/tutorials/inputs/drag_and_drop.html

## Implementation Tasks

### 1. EquipmentManager Script
Create `res://player/equipment_manager.gd`:
- Attached to Player node (from S03)
- 5 equipment slots: `weapon`, `helmet`, `torso`, `boots`, `accessories` (array, max 3)
- Methods: `equip_item(slot, item)`, `unequip_item(slot)`, `get_total_stat_bonuses()`
- Emit signals: `item_equipped(slot, item)`, `item_unequipped(slot)`, `stats_changed(new_stats)`

### 2. Equipment Definitions
Create `res://data/equipment.json`:
```json
{
  "equipment": [
    {
      "id": "iron_helmet",
      "name": "Iron Helmet",
      "slot": "helmet",
      "tier": 2,
      "icon_path": "res://assets/icons/equipment/iron_helmet.png",
      "stat_bonuses": {
        "defense": 5,
        "max_hp": 10
      },
      "resistances": {
        "physical": 0.1
      },
      "weight": 3.0,
      "value": 50
    }
  ]
}
```

Equipment types: helmets, torsos (armor), boots, accessories (amulets, rings)

### 3. Stat Bonus Calculation
Calculate total stat bonuses from all equipped items:
```gdscript
func get_total_stat_bonuses() -> Dictionary:
  var bonuses = {
    "defense": 0,
    "max_hp": 0,
    "speed": 0,
    "attack": 0
  }
  for slot in [weapon, helmet, torso, boots]:
    if slot != null:
      for stat in slot.stat_bonuses:
        bonuses[stat] += slot.stat_bonuses[stat]
  # Add accessories (max 3)
  for accessory in accessories:
    for stat in accessory.stat_bonuses:
      bonuses[stat] += accessory.stat_bonuses[stat]
  return bonuses
```

### 4. Apply Bonuses to Player
When equipment changes:
- Recalculate total stat bonuses
- Apply to Player stats (from S03)
- Update Combat stats (from S04)
- Emit `stats_changed` signal

### 5. Equipment UI
Create `res://ui/equipment_panel.tscn`:
- 5 equipment slot displays (weapon, helmet, torso, boots, accessories)
- Each slot shows equipped item icon or empty state
- Drag-drop support between Inventory UI (S05) and Equipment UI
- Right-click equipped item to unequip

### 6. Drag-Drop Implementation
- Drag item from Inventory UI → Equipment UI: Equip if valid slot
- Drag item from Equipment UI → Inventory UI: Unequip and return to inventory
- Validation: Only allow helmet in helmet slot, etc.

### 7. Visual Equipment (Optional)
- Add sprite layers to Player (from S03) for equipped items
- helmet_sprite, torso_sprite, boots_sprite layers
- Update sprites when equipment changes
- (Can be placeholder colored rectangles if no sprites yet)

### 8. Integration with Weapons (S07)
- Weapon slot uses WeaponResource from ItemDatabase
- Apply weapon damage to Combat stats

### 9. Integration with Save/Load (S06)
- EquipmentManager registers with SaveManager
- save_state() returns equipped items by ID
- load_state() re-equips items from IDs

### 10. Test Scene
Create `res://tests/test_equipment.tscn`:
- Player with equipment UI
- 10+ different equipment items to test
- Visual feedback showing stat changes
- Drag-drop testing

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://player/equipment_manager.gd` - Equipment manager with 5 slots, stat calculation
   - Complete implementations with full logic
   - Type hints, documentation, error handling
   - Integration with Player (S03), Inventory (S05), ItemDatabase (S07)

2. **Create all JSON data files** using the Write tool
   - `res://data/equipment.json` - Equipment definitions (helmets, torsos, boots, accessories)
   - Valid JSON format with all required fields

3. **Create HANDOFF-S08.md** documenting:
   - Scene structures needed (equipment UI, test scene)
   - MCP agent tasks (use GDAI tools)
   - Node hierarchies and property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- `res://player/equipment_manager.gd` - Complete EquipmentManager implementation
- `res://data/equipment.json` - Equipment database
- `HANDOFF-S08.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S08.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create equipment_panel.tscn, test_equipment.tscn
   - `add_node` - Build node hierarchies (equipment slots, drag-drop UI)
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set UI positions, slot configurations
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S08.md` with this structure:

```markdown
# HANDOFF: S08 - Equipment System

## Files Created by Claude Code Web

### GDScript Files
- `res://player/equipment_manager.gd` - Equipment manager with 5 slots, stat calculation

### Data Files
- `res://data/equipment.json` - Equipment definitions (helmets, torsos, boots, accessories)

## MCP Agent Tasks

### 1. Create Equipment Panel UI

```bash
# Create equipment panel scene
create_scene res://ui/equipment_panel.tscn
add_node res://ui/equipment_panel.tscn Panel EquipmentPanel root
add_node res://ui/equipment_panel.tscn VBoxContainer Layout EquipmentPanel
add_node res://ui/equipment_panel.tscn Label Title Layout
add_node res://ui/equipment_panel.tscn HBoxContainer EquipmentSlots Layout

# Add equipment slots
add_node res://ui/equipment_panel.tscn PanelContainer WeaponSlot EquipmentSlots
add_node res://ui/equipment_panel.tscn TextureRect WeaponIcon WeaponSlot
add_node res://ui/equipment_panel.tscn Label WeaponLabel WeaponSlot

add_node res://ui/equipment_panel.tscn PanelContainer HelmetSlot EquipmentSlots
add_node res://ui/equipment_panel.tscn TextureRect HelmetIcon HelmetSlot
add_node res://ui/equipment_panel.tscn Label HelmetLabel HelmetSlot

add_node res://ui/equipment_panel.tscn PanelContainer TorsoSlot EquipmentSlots
add_node res://ui/equipment_panel.tscn TextureRect TorsoIcon TorsoSlot
add_node res://ui/equipment_panel.tscn Label TorsoLabel TorsoSlot

add_node res://ui/equipment_panel.tscn PanelContainer BootsSlot EquipmentSlots
add_node res://ui/equipment_panel.tscn TextureRect BootsIcon BootsSlot
add_node res://ui/equipment_panel.tscn Label BootsLabel BootsSlot

# Add accessories section
add_node res://ui/equipment_panel.tscn Label AccessoriesTitle Layout
add_node res://ui/equipment_panel.tscn HBoxContainer AccessorySlots Layout

add_node res://ui/equipment_panel.tscn PanelContainer Accessory1Slot AccessorySlots
add_node res://ui/equipment_panel.tscn TextureRect Accessory1Icon Accessory1Slot

add_node res://ui/equipment_panel.tscn PanelContainer Accessory2Slot AccessorySlots
add_node res://ui/equipment_panel.tscn TextureRect Accessory2Icon Accessory2Slot

add_node res://ui/equipment_panel.tscn PanelContainer Accessory3Slot AccessorySlots
add_node res://ui/equipment_panel.tscn TextureRect Accessory3Icon Accessory3Slot

# Add stat display
add_node res://ui/equipment_panel.tscn VBoxContainer StatsDisplay Layout
add_node res://ui/equipment_panel.tscn Label StatDefense StatsDisplay
add_node res://ui/equipment_panel.tscn Label StatMaxHP StatsDisplay
add_node res://ui/equipment_panel.tscn Label StatSpeed StatsDisplay
add_node res://ui/equipment_panel.tscn Label StatAttack StatsDisplay
```

### 2. Configure Equipment Panel Properties

```bash
# Panel configuration
update_property res://ui/equipment_panel.tscn EquipmentPanel custom_minimum_size "Vector2(400, 500)"
update_property res://ui/equipment_panel.tscn EquipmentPanel anchor_preset 8

# Title
update_property res://ui/equipment_panel.tscn Title text "Equipment"
update_property res://ui/equipment_panel.tscn Title horizontal_alignment 1

# Slot labels
update_property res://ui/equipment_panel.tscn WeaponLabel text "Weapon"
update_property res://ui/equipment_panel.tscn HelmetLabel text "Helmet"
update_property res://ui/equipment_panel.tscn TorsoLabel text "Torso"
update_property res://ui/equipment_panel.tscn BootsLabel text "Boots"
update_property res://ui/equipment_panel.tscn AccessoriesTitle text "Accessories"

# Slot sizes
update_property res://ui/equipment_panel.tscn WeaponSlot custom_minimum_size "Vector2(64, 64)"
update_property res://ui/equipment_panel.tscn HelmetSlot custom_minimum_size "Vector2(64, 64)"
update_property res://ui/equipment_panel.tscn TorsoSlot custom_minimum_size "Vector2(64, 64)"
update_property res://ui/equipment_panel.tscn BootsSlot custom_minimum_size "Vector2(64, 64)"
update_property res://ui/equipment_panel.tscn Accessory1Slot custom_minimum_size "Vector2(48, 48)"
update_property res://ui/equipment_panel.tscn Accessory2Slot custom_minimum_size "Vector2(48, 48)"
update_property res://ui/equipment_panel.tscn Accessory3Slot custom_minimum_size "Vector2(48, 48)"

# Stat display
update_property res://ui/equipment_panel.tscn StatDefense text "Defense: +0"
update_property res://ui/equipment_panel.tscn StatMaxHP text "Max HP: +0"
update_property res://ui/equipment_panel.tscn StatSpeed text "Speed: +0"
update_property res://ui/equipment_panel.tscn StatAttack text "Attack: +0"
```

### 3. Create Test Scene

```bash
create_scene res://tests/test_equipment.tscn
add_node res://tests/test_equipment.tscn Node2D TestEquipment root
add_node res://tests/test_equipment.tscn CharacterBody2D Player TestEquipment
add_node res://tests/test_equipment.tscn Sprite2D PlayerSprite Player
add_node res://tests/test_equipment.tscn CollisionShape2D PlayerCollision Player

# Add equipment panel to test scene
add_node res://tests/test_equipment.tscn CanvasLayer UI TestEquipment
add_node res://tests/test_equipment.tscn Control EquipmentUI UI res://ui/equipment_panel.tscn

# Add test controls
add_node res://tests/test_equipment.tscn Label Instructions UI
add_node res://tests/test_equipment.tscn VBoxContainer TestButtons UI
add_node res://tests/test_equipment.tscn Button EquipHelmet TestButtons
add_node res://tests/test_equipment.tscn Button UnequipHelmet TestButtons
add_node res://tests/test_equipment.tscn Button ShowStats TestButtons

# Configure test scene
update_property res://tests/test_equipment.tscn Player position "Vector2(400, 300)"
update_property res://tests/test_equipment.tscn PlayerCollision shape "CircleShape2D(radius=16)"
update_property res://tests/test_equipment.tscn Instructions text "Test Equipment System: Equip/unequip items and check stat bonuses"
update_property res://tests/test_equipment.tscn Instructions position "Vector2(10, 10)"
update_property res://tests/test_equipment.tscn EquipHelmet text "Equip Iron Helmet"
update_property res://tests/test_equipment.tscn UnequipHelmet text "Unequip Helmet"
update_property res://tests/test_equipment.tscn ShowStats text "Show Total Stats"
```

## Testing Checklist

Use Godot MCP tools to test:

```bash
# Run test scene
play_scene res://tests/test_equipment.tscn

# Check for errors
get_godot_errors
```

### Verify:
- [ ] Equipment panel displays all 5 equipment slots
- [ ] Weapon, helmet, torso, boots slots visible
- [ ] 3 accessory slots visible
- [ ] Equipping item applies stat bonuses
- [ ] Unequipping item removes stat bonuses
- [ ] Stat display updates when equipment changes
- [ ] Multiple accessories can be equipped (max 3)
- [ ] Drag-drop between inventory and equipment works
- [ ] Slot validation prevents wrong item types

### Integration Points:
- **S03 (Player)**: EquipmentManager attached to Player node
- **S05 (Inventory)**: Drag-drop integration
- **S07 (Weapons Database)**: Weapon slot uses WeaponResource
- **S04 (Combat)**: Stat bonuses apply to combat calculations
- **S06 (Save/Load)**: Equipment persists across saves

## Completion

Update COORDINATION-DASHBOARD.md:
- Mark S08 as complete
- Release any locked resources
- Unblock S09 (Dodge/Block) and S25 (Crafting)
- Note: Job 2 complete - all foundation systems ready
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S08.md, verify:

### Code Quality
- [ ] equipment_manager.gd created with complete implementation (no TODOs or placeholders)
- [ ] equipment.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented where needed
- [ ] Integration patterns documented (signals, method calls)

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (player/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S08.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] EquipmentManager with 5 equipment slots (weapon, helmet, torso, boots, accessories)
- [ ] equip_item(), unequip_item(), get_total_stat_bonuses() methods implemented
- [ ] Stat bonus calculation logic implemented
- [ ] Equipment definitions in equipment.json (helmets, torsos, boots, accessories)
- [ ] Integration with Player (S03), Inventory (S05), ItemDatabase (S07) documented
- [ ] Validation logic for correct slot types implemented

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] All scenes created using `create_scene`
- [ ] All nodes added using `add_node` in correct hierarchy
- [ ] All scripts attached using `attach_script`
- [ ] All properties set using `update_property`

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S08")`
- [ ] Quality gates passed: `check_quality_gates("S08")`
- [ ] Checkpoint validated: `validate_checkpoint("S08")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked (Job 2 complete)
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] EquipmentManager correctly manages 5 equipment slots
- [ ] Equipping item applies stat bonuses to Player
- [ ] Unequipping item removes stat bonuses
- [ ] Multiple accessories can be equipped (max 3)
- [ ] Equipment UI displays all equipped items with icons
- [ ] Drag-drop between Inventory and Equipment works
- [ ] Validation prevents equipping helmet in boots slot, etc.
- [ ] Stat changes reflected in Combat (S04) damage/defense calculations
- [ ] Integration with Weapons (S07) applies weapon damage
- [ ] Integration with Save/Load (S06) persists equipped items
- [ ] (Optional) Visual equipment appears on player sprite

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ equipment_manager.gd complete with 5-slot management
- ✅ equipment.json complete with equipment definitions
- ✅ HANDOFF-S08.md provides clear MCP agent instructions
- ✅ Stat calculation logic implemented
- ✅ Integration patterns documented for S03, S05, S06, S07

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Equipment UI configured correctly in Godot editor
- ✅ All 5 equipment slots work correctly
- ✅ Equip/unequip applies/removes stat bonuses
- ✅ Drag-drop UI works between Inventory and Equipment
- ✅ Slot validation prevents incorrect equipment placement
- ✅ All verification criteria pass
- ✅ Job 2 complete - all foundation systems (S01-S08) ready
- ✅ System ready for dependent systems (S09, S25) and Job 3 systems

</success_criteria>

<memory_checkpoint_format>
```
System S08 (Equipment) Complete

FILES CREATED:
- res://player/equipment_manager.gd (EquipmentManager script)
- res://data/equipment.json (Equipment definitions: helmets, armor, boots, accessories)
- res://ui/equipment_panel.tscn (Equipment UI with drag-drop)
- res://tests/test_equipment.tscn (Equipment test scene)

EQUIPMENT SLOTS:
- Weapon: 1 slot (uses WeaponResource from S07)
- Helmet: 1 slot
- Torso: 1 slot
- Boots: 1 slot
- Accessories: 3 slots max

STAT BONUSES:
- Defense, Max HP, Speed, Attack
- Resistances (physical, fire, ice, etc.)
- Weight (affects movement speed)

METHODS:
- equip_item(slot, item)
- unequip_item(slot)
- get_total_stat_bonuses() -> Dictionary

SIGNALS:
- item_equipped(slot, item)
- item_unequipped(slot)
- stats_changed(new_stats)

UI FEATURES:
- Drag-drop from Inventory to Equipment
- Drag-drop from Equipment to Inventory (unequip)
- Visual feedback for equipped items
- Slot validation (helmet only in helmet slot)

INTEGRATION:
- Uses Inventory (S05) for item storage
- Uses Weapons Database (S07) for weapon stats
- Applies stats to Player (S03) and Combat (S04)
- Saves/loads with SaveManager (S06)
- Ready for S09 (Dodge/Block) to use equipment stats
- Ready for S25 (Crafting) for equipment enhancement

VISUAL EQUIPMENT:
- Optional sprite layers on Player (S03)
- helmet_sprite, torso_sprite, boots_sprite
- Updates when equipment changes

EXTENSIBILITY:
- Add new equipment: Simply add JSON entry to equipment.json
- Add new stat bonuses: Add to stat_bonuses dictionary
- No code changes needed for new equipment types

JOB 2 COMPLETE:
All foundation systems (S01-S08) implemented and integrated.
Ready for Job 3 (S09-S18).

STATUS: Job 2 complete, ready for Job 3
```
</memory_checkpoint_format>
