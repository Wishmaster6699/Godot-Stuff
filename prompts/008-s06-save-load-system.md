<objective>
Implement Save/Load System (S06) - save anywhere functionality with multiple save slots. Serializes player stats, inventory, position, progress flags, and NPC states using Godot's FileAccess API with JSON format.

DEPENDS ON: S03 (Player), S05 (Inventory)
CRITICAL: All future systems must integrate with this system to persist state
</objective>

<context>
The Save/Load System is the persistence layer for the entire game. It must serialize:
- Player position, stats, resonance alignment
- Inventory contents (all items)
- Equipment (once S08 is complete)
- Progress flags (quests, events, doors unlocked)
- NPC states (dialogue progress, relationships)
- World state (items collected, bosses defeated)

All future systems (S07-S26) must register their saveable state with SaveManager.

Reference:
@rhythm-rpg-implementation-guide.md (lines 720-855 for S06 specification)
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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S06")`
- [ ] Quality gates: `check_quality_gates("S06")`
- [ ] Checkpoint validation: `validate_checkpoint("S06")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S06", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<file_isolation>

## 🚨 FILE ISOLATION RULES - PREVENT MERGE CONFLICTS

**System ID:** S06 | **System Name:** Save/Load

**✅ YOU MAY MODIFY:**
```
src/systems/s06-saveload/
scenes/s06-saveload/
checkpoints/s06-saveload-checkpoint.md
research/s06-saveload-research.md
HANDOFF-S06-SAVELOAD.md
```

**❌ YOU MUST NOT MODIFY:** Other systems' directories, `src/core/`, `project.godot`

**See `GIT-WORKFLOW.md` for complete file isolation rules.**

</file_isolation>

<requirements>

## Web Research First
- "Godot 4.5 save system best practices 2025"
- "Godot FileAccess API"
- "Godot JSON serialization"
- https://docs.godotengine.org/en/4.5/classes/class_fileaccess.html

## Implementation Tasks

### 1. SaveManager Autoload
Create `res://autoloads/save_manager.gd`:
- Singleton autoload
- Methods: `save_game(slot_id)`, `load_game(slot_id)`, `delete_save(slot_id)`, `get_save_slots()`
- Save location: `user://saves/save_slot_[N].json`
- 3 save slots supported

### 2. Save File Structure
Define JSON structure:
```json
{
  "save_file": {
    "metadata": {
      "save_slot": 1,
      "timestamp": "2025-01-17T08:00:00Z",
      "play_time_seconds": 3600,
      "game_version": "0.1.0",
      "location": "Starter Town"
    },
    "player": {
      "position": { "x": 100, "y": 200 },
      "stats": {
        "level": 5,
        "hp": 80,
        "max_hp": 100,
        "xp": 250
      }
    },
    "inventory": {
      "items": [
        { "id": "health_potion", "quantity": 5 }
      ]
    },
    "progress": {
      "flags": ["tutorial_complete"],
      "quests_active": ["find_lost_item"],
      "quests_completed": ["tutorial_quest"]
    },
    "world_state": {
      "doors_unlocked": ["starter_town_gate"],
      "items_collected": ["key_item_1"]
    }
  }
}
```

### 3. Saveable System Registration
Systems register with SaveManager:
```gdscript
func _ready():
  SaveManager.register_saveable(self, "system_name")

func save_state() -> Dictionary:
  return { "custom_data": my_data }

func load_state(data: Dictionary):
  my_data = data.custom_data
```

### 4. Save/Load Implementation
- `save_game(slot_id)`: Gather data from all registered systems, serialize to JSON, write to file
- `load_game(slot_id)`: Read file, deserialize JSON, restore state to all systems
- Error handling: Handle corrupted saves gracefully (don't crash)

### 5. Save Slot Management
- `get_save_slots()`: Returns array of save metadata (timestamp, play_time, location)
- `delete_save(slot_id)`: Deletes save file
- Auto-save (optional): Every 5 minutes or after major events

### 6. Test Scene
Create `res://tests/test_save_load.tscn`:
- Save game button
- Load game button
- Modify player state between saves
- Verify state restores correctly

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://autoloads/save_manager.gd` - SaveManager singleton with save/load/delete methods
   - Complete implementations with full logic
   - Type hints, documentation, error handling
   - JSON serialization/deserialization
   - Integration with Player (S03) and Inventory (S05)

2. **Create HANDOFF-S06.md** documenting:
   - Scene structures needed (save/load UI, test scene)
   - MCP agent tasks (use GDAI tools)
   - Autoload registration instructions
   - Testing steps for MCP agent

### Your Deliverables:
- `res://autoloads/save_manager.gd` - Complete SaveManager implementation
- `HANDOFF-S06.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)
- Register autoload in project settings (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S06.md
2. Use GDAI tools to configure scenes:
   - Register SaveManager as autoload in project settings
   - `create_scene` - Create test_save_load.tscn
   - `add_node` - Build node hierarchies (UI for save/load buttons)
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set UI positions and properties
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S06.md` with this structure:

```markdown
# HANDOFF: S06 - Save/Load System

## Files Created by Claude Code Web

### GDScript Files
- `res://autoloads/save_manager.gd` - SaveManager singleton with save/load/delete methods and system registration

### Data Files
- None (creates save files in `user://saves/` directory at runtime)
- Save format: JSON files named `save_slot_[N].json` (N = 1-3)

## MCP Agent Tasks

### 1. Register SaveManager as Autoload

```bash
# Register SaveManager as autoload singleton
# In Godot Editor: Project → Project Settings → Autoload
# Add: res://autoloads/save_manager.gd with name "SaveManager"
# This must be done manually in the Godot editor or via project.godot file
```

**Note:** Add this to `project.godot` file under `[autoload]` section:
```
SaveManager="*res://autoloads/save_manager.gd"
```

### 2. Create Save/Load UI Scene

```bash
# Create save/load UI scene
create_scene res://ui/save_load_ui.tscn
add_node res://ui/save_load_ui.tscn Panel SaveLoadPanel root
add_node res://ui/save_load_ui.tscn VBoxContainer Layout SaveLoadPanel
add_node res://ui/save_load_ui.tscn Label Title Layout

# Add save slot buttons
add_node res://ui/save_load_ui.tscn HBoxContainer Slot1Row Layout
add_node res://ui/save_load_ui.tscn Label Slot1Info Slot1Row
add_node res://ui/save_load_ui.tscn Button SaveSlot1 Slot1Row
add_node res://ui/save_load_ui.tscn Button LoadSlot1 Slot1Row
add_node res://ui/save_load_ui.tscn Button DeleteSlot1 Slot1Row

add_node res://ui/save_load_ui.tscn HBoxContainer Slot2Row Layout
add_node res://ui/save_load_ui.tscn Label Slot2Info Slot2Row
add_node res://ui/save_load_ui.tscn Button SaveSlot2 Slot2Row
add_node res://ui/save_load_ui.tscn Button LoadSlot2 Slot2Row
add_node res://ui/save_load_ui.tscn Button DeleteSlot2 Slot2Row

add_node res://ui/save_load_ui.tscn HBoxContainer Slot3Row Layout
add_node res://ui/save_load_ui.tscn Label Slot3Info Slot3Row
add_node res://ui/save_load_ui.tscn Button SaveSlot3 Slot3Row
add_node res://ui/save_load_ui.tscn Button LoadSlot3 Slot3Row
add_node res://ui/save_load_ui.tscn Button DeleteSlot3 Slot3Row

# Configure panel
update_property res://ui/save_load_ui.tscn SaveLoadPanel custom_minimum_size "Vector2(600, 300)"
update_property res://ui/save_load_ui.tscn SaveLoadPanel anchor_preset 8
update_property res://ui/save_load_ui.tscn Title text "Save/Load Game"
update_property res://ui/save_load_ui.tscn Title horizontal_alignment 1

# Configure slot 1 buttons
update_property res://ui/save_load_ui.tscn Slot1Info text "Slot 1: Empty"
update_property res://ui/save_load_ui.tscn Slot1Info custom_minimum_size "Vector2(300, 0)"
update_property res://ui/save_load_ui.tscn SaveSlot1 text "Save"
update_property res://ui/save_load_ui.tscn LoadSlot1 text "Load"
update_property res://ui/save_load_ui.tscn DeleteSlot1 text "Delete"

# Configure slot 2 buttons
update_property res://ui/save_load_ui.tscn Slot2Info text "Slot 2: Empty"
update_property res://ui/save_load_ui.tscn Slot2Info custom_minimum_size "Vector2(300, 0)"
update_property res://ui/save_load_ui.tscn SaveSlot2 text "Save"
update_property res://ui/save_load_ui.tscn LoadSlot2 text "Load"
update_property res://ui/save_load_ui.tscn DeleteSlot2 text "Delete"

# Configure slot 3 buttons
update_property res://ui/save_load_ui.tscn Slot3Info text "Slot 3: Empty"
update_property res://ui/save_load_ui.tscn Slot3Info custom_minimum_size "Vector2(300, 0)"
update_property res://ui/save_load_ui.tscn SaveSlot3 text "Save"
update_property res://ui/save_load_ui.tscn LoadSlot3 text "Load"
update_property res://ui/save_load_ui.tscn DeleteSlot3 text "Delete"
```

### 3. Create Test Scene

```bash
create_scene res://tests/test_save_load.tscn
add_node res://tests/test_save_load.tscn Node2D TestSaveLoad root
add_node res://tests/test_save_load.tscn CharacterBody2D Player TestSaveLoad
add_node res://tests/test_save_load.tscn Sprite2D PlayerSprite Player
add_node res://tests/test_save_load.tscn CollisionShape2D PlayerCollision Player

# Add UI layer
add_node res://tests/test_save_load.tscn CanvasLayer UI TestSaveLoad
add_node res://tests/test_save_load.tscn Control SaveLoadUI UI res://ui/save_load_ui.tscn

# Add test controls
add_node res://tests/test_save_load.tscn VBoxContainer TestControls UI
add_node res://tests/test_save_load.tscn Label Instructions TestControls
add_node res://tests/test_save_load.tscn Button ModifyPlayer TestControls
add_node res://tests/test_save_load.tscn Button AddInventoryItem TestControls
add_node res://tests/test_save_load.tscn Label PlayerState TestControls

# Configure test scene
update_property res://tests/test_save_load.tscn Player position "Vector2(400, 300)"
update_property res://tests/test_save_load.tscn PlayerCollision shape "CircleShape2D(radius=16)"
update_property res://tests/test_save_load.tscn Instructions text "Test Save/Load: 1) Modify player state 2) Save to slot 3) Change state again 4) Load from slot 5) Verify state restored"
update_property res://tests/test_save_load.tscn Instructions position "Vector2(10, 10)"
update_property res://tests/test_save_load.tscn Instructions custom_minimum_size "Vector2(780, 60)"
update_property res://tests/test_save_load.tscn ModifyPlayer text "Move Player & Change Stats"
update_property res://tests/test_save_load.tscn AddInventoryItem text "Add Item to Inventory"
update_property res://tests/test_save_load.tscn PlayerState text "Player State: Position (400, 300), HP: 100/100"
update_property res://tests/test_save_load.tscn TestControls position "Vector2(10, 80)"
```

## Testing Checklist

Use Godot MCP tools to test:

```bash
# Run test scene
play_scene res://tests/test_save_load.tscn

# Check for errors
get_godot_errors

# Verify save directory exists (after first save)
# Check: user://saves/ directory should be created
```

### Verify:
- [ ] SaveManager autoload registered and accessible globally (`SaveManager` works in any script)
- [ ] save_game(slot_id) creates JSON file in `user://saves/save_slot_[N].json`
- [ ] Save file includes all sections: metadata, player, inventory, progress, world_state
- [ ] Metadata includes: timestamp, play_time, location, game_version
- [ ] Player state saves: position, stats (level, hp, max_hp, xp)
- [ ] Inventory state saves: all items with quantities
- [ ] load_game(slot_id) restores player position correctly
- [ ] load_game(slot_id) restores player stats correctly
- [ ] load_game(slot_id) restores inventory items correctly
- [ ] Multiple save slots work independently (save to slot 1, save different state to slot 2, load slot 1 = original state)
- [ ] delete_save(slot_id) removes save file
- [ ] get_save_slots() returns array with metadata for each slot
- [ ] System handles missing save files gracefully (returns error, doesn't crash)
- [ ] System handles corrupted JSON gracefully (returns error, doesn't crash)

### Integration Points:
- **S03 (Player)**: Registered with SaveManager, implements save_state() and load_state()
- **S05 (Inventory)**: Registered with SaveManager, implements save_state() and load_state()
- **Future Systems (S07-S26)**: Must call `SaveManager.register_saveable(self, "system_name")` in _ready()

### Save File Structure Verification:
Check that generated JSON files have this structure:
```json
{
  "save_file": {
    "metadata": { "save_slot": 1, "timestamp": "...", "play_time_seconds": 0, "game_version": "0.1.0", "location": "..." },
    "player": { "position": {...}, "stats": {...} },
    "inventory": { "items": [...] },
    "progress": { "flags": [...], "quests_active": [...], "quests_completed": [...] },
    "world_state": { "doors_unlocked": [...], "items_collected": [...] }
  }
}
```

## Completion

Update COORDINATION-DASHBOARD.md:
- Mark S06 as complete
- Release any locked resources
- Unblock all future systems (S07-S26) - they can now integrate save/load
- **CRITICAL NOTE**: All future system implementations MUST include save/load integration
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S06.md, verify:

### Code Quality
- [ ] save_manager.gd created with complete implementation (no TODOs or placeholders)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented (corrupted files, missing files)
- [ ] JSON serialization/deserialization logic implemented
- [ ] Integration patterns documented (signals, method calls)

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (autoloads/)
- [ ] Code follows GDScript style guide
- [ ] HANDOFF-S06.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] SaveManager with save_game(), load_game(), delete_save() methods
- [ ] Registration system for saveable components implemented
- [ ] Save file structure defined (metadata, player, inventory, progress, world_state)
- [ ] Multiple save slot support (3 slots)
- [ ] Error handling for corrupted saves implemented
- [ ] Integration with Player (S03) and Inventory (S05) documented

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] SaveManager registered as autoload in project settings
- [ ] Test scene created using `create_scene`
- [ ] All nodes added using `add_node` in correct hierarchy
- [ ] All scripts attached using `attach_script`
- [ ] All properties set using `update_property`

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S06")`
- [ ] Quality gates passed: `check_quality_gates("S06")`
- [ ] Checkpoint validated: `validate_checkpoint("S06")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] save_game() creates JSON file in user:// directory
- [ ] load_game() restores player position, stats, inventory
- [ ] Multiple save slots work independently (3 slots)
- [ ] Save file includes metadata (timestamp, play time, location)
- [ ] delete_save() removes file correctly
- [ ] System handles corrupted save files gracefully (error message, don't crash)
- [ ] Player (S03) state saves/loads correctly
- [ ] Inventory (S05) state saves/loads correctly

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ save_manager.gd complete with all serialization logic
- ✅ HANDOFF-S06.md provides clear MCP agent instructions
- ✅ Registration system for saveable components implemented
- ✅ Error handling for corrupted files implemented
- ✅ Integration patterns documented for Player (S03) and Inventory (S05)

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ SaveManager registered as autoload and accessible globally
- ✅ Save files created in user:// directory with correct structure
- ✅ Load restores all state correctly
- ✅ Multiple save slots work independently
- ✅ Corrupted file handling works gracefully
- ✅ All verification criteria pass
- ✅ System ready for all future systems to integrate (S07-S26)

</success_criteria>

<memory_checkpoint_format>
```
System S06 (Save/Load) Complete

FILES CREATED:
- res://autoloads/save_manager.gd (SaveManager singleton)
- res://tests/test_save_load.tscn (Test scene)

SAVE SLOTS:
- 3 slots supported
- Location: user://saves/save_slot_[N].json
- Format: JSON

SAVE FILE INCLUDES:
- Metadata (timestamp, play_time, location, version)
- Player (position, stats, HP, XP)
- Inventory (all items)
- Progress (flags, active quests, completed quests)
- World state (doors unlocked, items collected)

METHODS:
- save_game(slot_id)
- load_game(slot_id)
- delete_save(slot_id)
- get_save_slots() -> Array[Dictionary]

SYSTEM REGISTRATION:
- Systems call SaveManager.register_saveable(self, "system_name")
- Implement save_state() -> Dictionary
- Implement load_state(data: Dictionary)

INTEGRATION:
- Player (S03) registered and saving/loading
- Inventory (S05) registered and saving/loading
- All future systems (S07-S26) MUST register with SaveManager

CRITICAL NOTE:
All future system implementations must include save/load integration.

STATUS: Ready for all future systems to integrate
```
</memory_checkpoint_format>
