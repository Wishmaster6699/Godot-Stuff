# System S22 Handoff - Complex NPC System

**Created by:** Claude Code Web
**Date:** 2025-11-18
**Status:** Ready for MCP Agent Configuration

---

## Files Created (Tier 1 Complete)

### GDScript Files
- ✅ `src/systems/s22-npc-system/npc_base.gd` - Complete NPC base class (500+ lines)
  - Relationship tracking (0-100 scale with thresholds)
  - Dialogue state management (flags and variables)
  - Schedule system (time-based location/activity)
  - Dialogue Manager integration
  - Quest trigger system
  - Save/load support
  - Integration with S21 Alignment system
  - Comprehensive debug tools
  - 30+ public methods with full type hints
  - 6 signals for event handling

### Data Files
- ✅ `data/npc_config.json` - NPC configuration (180+ lines)
  - Relationship thresholds (stranger to best friend)
  - 18 relationship action modifiers
  - 5 complete NPC definitions (elder, shopkeeper, bard, guardian, researcher)
  - NPC schedules with time/location/activity
  - Quest trigger conditions
  - Alignment reaction rules
  - Time period definitions

### Dialogue Files
- ✅ `src/systems/s22-npc-system/dialogue/elder.dialogue` - Sample dialogue tree (300+ lines)
  - Alignment-based dialogue branches (authentic/algorithmic/neutral)
  - Relationship-based greetings and responses
  - Quest triggers (find_lost_necklace, restore_harmony)
  - Dialogue state tracking (met_elder, quest flags)
  - Relationship mutations (dynamic relationship changes)
  - 15+ dialogue branches with conditional logic
  - Integration with ResonanceAlignment autoload

### Documentation
- ✅ `research/s22-npc-system-research.md` - Complete research findings (500+ lines)

**All files validated:** Syntax ✓ | Type hints ✓ | Documentation ✓ | GDScript 4.5 ✓

---

## Plugin Installation Required (MCP Agent)

### CRITICAL: Dialogue Manager Plugin

**This system requires the Dialogue Manager plugin to function!**

#### Installation Method 1: AssetLib (Recommended)
1. Open Godot Editor
2. Go to **AssetLib** tab (top bar)
3. Search for "Dialogue Manager"
4. Find "Dialogue Manager" by Nathan Hoad
5. Click **Download** → **Install**
6. Go to **Project** → **Project Settings** → **Plugins**
7. Enable **Dialogue Manager** checkbox
8. Restart Godot editor

#### Installation Method 2: GitHub Clone
1. Clone repository: `https://github.com/nathanhoad/godot_dialogue_manager`
2. Copy `addons/dialogue_manager/` folder to your `res://addons/` directory
3. Go to **Project** → **Project Settings** → **Plugins**
4. Enable **Dialogue Manager** checkbox
5. Restart Godot editor

#### Verification
After installation, verify:
- **DialogueManager** autoload appears in Project Settings → Autoload
- `.dialogue` files show special icon in FileSystem
- Double-clicking `.dialogue` file opens Dialogue Editor

**Required Version:** v3.4+ (Godot 4.4+ compatible)
**Documentation:** https://github.com/nathanhoad/godot_dialogue_manager/tree/main/docs

---

## Scene Configuration Needed (Tier 2 - MCP Agent Tasks)

### Scene 1: `res://tests/test_npc.tscn`

**Purpose:** Test NPC system with interactive UI

**MCP Agent Commands:**
```gdscript
# Create test scene with Node2D root
create_scene("res://tests/test_npc.tscn", "Node2D", "TestNPC")

# Add NPC character with base script
add_node("TestNPC", "CharacterBody2D", "ElderNPC")
attach_script("TestNPC/ElderNPC", "res://src/systems/s22-npc-system/npc_base.gd")

# Configure Elder NPC properties
update_property("TestNPC/ElderNPC", "npc_id", "elder")
update_property("TestNPC/ElderNPC", "npc_name", "Village Elder")
update_property("TestNPC/ElderNPC", "dialogue_file_path", "res://src/systems/s22-npc-system/dialogue/elder.dialogue")
update_property("TestNPC/ElderNPC", "alignment_preference", "authentic")
update_property("TestNPC/ElderNPC", "starting_relationship", 50)
update_property("TestNPC/ElderNPC", "position", Vector2(400, 300))

# Add visual representation (placeholder)
add_node("TestNPC/ElderNPC", "Sprite2D", "Sprite")
update_property("TestNPC/ElderNPC/Sprite", "modulate", Color(0.8, 0.7, 0.5, 1.0))  # Brownish for elder

# Add collision shape
add_node("TestNPC/ElderNPC", "CollisionShape2D", "CollisionShape")
# Note: Will need to set shape in Godot editor manually or via add_resource

# Add UI Panel for info display
add_node("TestNPC", "Panel", "InfoPanel")
update_property("TestNPC/InfoPanel", "position", Vector2(10, 10))
update_property("TestNPC/InfoPanel", "size", Vector2(400, 200))

# Add VBoxContainer for organized info
add_node("TestNPC/InfoPanel", "VBoxContainer", "InfoContainer")
update_property("TestNPC/InfoPanel/InfoContainer", "position", Vector2(10, 10))

# Add info labels
add_node("TestNPC/InfoPanel/InfoContainer", "Label", "NPCNameLabel")
update_property("TestNPC/InfoPanel/InfoContainer/NPCNameLabel", "text", "NPC: Village Elder")

add_node("TestNPC/InfoPanel/InfoContainer", "Label", "RelationshipLabel")
update_property("TestNPC/InfoPanel/InfoContainer/RelationshipLabel", "text", "Relationship: 50/100 (Friend)")

add_node("TestNPC/InfoPanel/InfoContainer", "Label", "AlignmentLabel")
update_property("TestNPC/InfoPanel/InfoContainer/AlignmentLabel", "text", "Alignment Preference: Authentic")

add_node("TestNPC/InfoPanel/InfoContainer", "Label", "LocationLabel")
update_property("TestNPC/InfoPanel/InfoContainer/LocationLabel", "text", "Location: town_square")

add_node("TestNPC/InfoPanel/InfoContainer", "Label", "ActivityLabel")
update_property("TestNPC/InfoPanel/InfoContainer/ActivityLabel", "text", "Activity: greeting_visitors")

# Add player alignment display
add_node("TestNPC/InfoPanel/InfoContainer", "Label", "PlayerAlignmentLabel")
update_property("TestNPC/InfoPanel/InfoContainer/PlayerAlignmentLabel", "text", "Player Alignment: 0")

# Add control panel for testing
add_node("TestNPC", "Panel", "ControlPanel")
update_property("TestNPC/ControlPanel", "position", Vector2(10, 230))
update_property("TestNPC/ControlPanel", "size", Vector2(400, 250))

add_node("TestNPC/ControlPanel", "VBoxContainer", "ButtonContainer")
update_property("TestNPC/ControlPanel/ButtonContainer", "position", Vector2(10, 10))

# Add test buttons
add_node("TestNPC/ControlPanel/ButtonContainer", "Button", "TalkButton")
update_property("TestNPC/ControlPanel/ButtonContainer/TalkButton", "text", "Talk to Elder")

add_node("TestNPC/ControlPanel/ButtonContainer", "Button", "GiveGiftButton")
update_property("TestNPC/ControlPanel/ButtonContainer/GiveGiftButton", "text", "Give Gift (+5 Relationship)")

add_node("TestNPC/ControlPanel/ButtonContainer", "Button", "InsultButton")
update_property("TestNPC/ControlPanel/ButtonContainer/InsultButton", "text", "Insult Elder (-10 Relationship)")

add_node("TestNPC/ControlPanel/ButtonContainer", "Button", "SetTime0800Button")
update_property("TestNPC/ControlPanel/ButtonContainer/SetTime0800Button", "text", "Set Time: 08:00 (Town Square)")

add_node("TestNPC/ControlPanel/ButtonContainer", "Button", "SetTime1800Button")
update_property("TestNPC/ControlPanel/ButtonContainer/SetTime1800Button", "text", "Set Time: 18:00 (Tavern)")

add_node("TestNPC/ControlPanel/ButtonContainer", "Button", "IncreaseAlignmentButton")
update_property("TestNPC/ControlPanel/ButtonContainer/IncreaseAlignmentButton", "text", "Player More Authentic (+10)")

add_node("TestNPC/ControlPanel/ButtonContainer", "Button", "DecreaseAlignmentButton")
update_property("TestNPC/ControlPanel/ButtonContainer/DecreaseAlignmentButton", "text", "Player More Algorithmic (-10)")

add_node("TestNPC/ControlPanel/ButtonContainer", "Button", "DebugInfoButton")
update_property("TestNPC/ControlPanel/ButtonContainer/DebugInfoButton", "text", "Print Debug Info")

# Add test controller script (create this file with test logic)
# attach_script("TestNPC", "res://tests/test_npc_controller.gd")
```

**Node Hierarchy:**
```
TestNPC (Node2D)
├── ElderNPC (CharacterBody2D) [npc_base.gd]
│   ├── Sprite (Sprite2D)
│   └── CollisionShape (CollisionShape2D)
├── InfoPanel (Panel)
│   └── InfoContainer (VBoxContainer)
│       ├── NPCNameLabel (Label)
│       ├── RelationshipLabel (Label)
│       ├── AlignmentLabel (Label)
│       ├── LocationLabel (Label)
│       ├── ActivityLabel (Label)
│       └── PlayerAlignmentLabel (Label)
└── ControlPanel (Panel)
    └── ButtonContainer (VBoxContainer)
        ├── TalkButton (Button)
        ├── GiveGiftButton (Button)
        ├── InsultButton (Button)
        ├── SetTime0800Button (Button)
        ├── SetTime1800Button (Button)
        ├── IncreaseAlignmentButton (Button)
        ├── DecreaseAlignmentButton (Button)
        └── DebugInfoButton (Button)
```

### Test Controller Script

**Create:** `res://tests/test_npc_controller.gd`

```gdscript
# Godot 4.5 | GDScript 4.5
# Test controller for NPC system

extends Node2D

@onready var elder_npc: NPCBase = $ElderNPC
@onready var relationship_label: Label = $InfoPanel/InfoContainer/RelationshipLabel
@onready var location_label: Label = $InfoPanel/InfoContainer/LocationLabel
@onready var activity_label: Label = $InfoPanel/InfoContainer/ActivityLabel
@onready var player_alignment_label: Label = $InfoPanel/InfoContainer/PlayerAlignmentLabel

func _ready() -> void:
	# Connect buttons
	$ControlPanel/ButtonContainer/TalkButton.pressed.connect(_on_talk_pressed)
	$ControlPanel/ButtonContainer/GiveGiftButton.pressed.connect(_on_give_gift_pressed)
	$ControlPanel/ButtonContainer/InsultButton.pressed.connect(_on_insult_pressed)
	$ControlPanel/ButtonContainer/SetTime0800Button.pressed.connect(_on_set_time_0800_pressed)
	$ControlPanel/ButtonContainer/SetTime1800Button.pressed.connect(_on_set_time_1800_pressed)
	$ControlPanel/ButtonContainer/IncreaseAlignmentButton.pressed.connect(_on_increase_alignment_pressed)
	$ControlPanel/ButtonContainer/DecreaseAlignmentButton.pressed.connect(_on_decrease_alignment_pressed)
	$ControlPanel/ButtonContainer/DebugInfoButton.pressed.connect(_on_debug_info_pressed)

	# Connect NPC signals
	elder_npc.relationship_changed.connect(_on_relationship_changed)
	elder_npc.schedule_changed.connect(_on_schedule_changed)
	elder_npc.dialogue_started.connect(_on_dialogue_started)
	elder_npc.dialogue_ended.connect(_on_dialogue_ended)

	# Update UI
	_update_ui()

func _update_ui() -> void:
	relationship_label.text = "Relationship: %d/100 (%s)" % [elder_npc.relationship, elder_npc.get_relationship_level()]
	location_label.text = "Location: %s" % elder_npc.current_location
	activity_label.text = "Activity: %s" % elder_npc.current_activity

	if ResonanceAlignment:
		player_alignment_label.text = "Player Alignment: %.1f (%s)" % [ResonanceAlignment.get_alignment(), ResonanceAlignment.get_alignment_type()]

func _on_talk_pressed() -> void:
	elder_npc.start_dialogue()

func _on_give_gift_pressed() -> void:
	elder_npc.apply_relationship_action("give_gift")

func _on_insult_pressed() -> void:
	elder_npc.apply_relationship_action("insult_npc")

func _on_set_time_0800_pressed() -> void:
	elder_npc.update_schedule_for_time("08:00")
	_update_ui()

func _on_set_time_1800_pressed() -> void:
	elder_npc.update_schedule_for_time("18:00")
	_update_ui()

func _on_increase_alignment_pressed() -> void:
	if ResonanceAlignment:
		ResonanceAlignment.shift_alignment(10.0, "test_button")
		_update_ui()

func _on_decrease_alignment_pressed() -> void:
	if ResonanceAlignment:
		ResonanceAlignment.shift_alignment(-10.0, "test_button")
		_update_ui()

func _on_debug_info_pressed() -> void:
	elder_npc.print_debug_info()

func _on_relationship_changed(npc_id: String, new_value: int, old_value: int, reason: String) -> void:
	print("[NPC] Relationship changed: %d → %d (reason: %s)" % [old_value, new_value, reason])
	_update_ui()

func _on_schedule_changed(npc_id: String, location: String, activity: String) -> void:
	print("[NPC] Schedule changed: %s → %s at %s" % [npc_id, activity, location])
	_update_ui()

func _on_dialogue_started(npc_id: String) -> void:
	print("[NPC] Dialogue started with: %s" % npc_id)

func _on_dialogue_ended(npc_id: String) -> void:
	print("[NPC] Dialogue ended with: %s" % npc_id)
	_update_ui()
```

**MCP Command to create test controller:**
```gdscript
# Create test controller script
create_script("res://tests/test_npc_controller.gd", [contents above])

# Attach to test scene root
attach_script("TestNPC", "res://tests/test_npc_controller.gd")
```

---

## Integration Points

### Signals Exposed

```gdscript
# Emitted when relationship value changes
signal relationship_changed(npc_id: String, new_value: int, old_value: int, reason: String)

# Emitted when dialogue starts/ends
signal dialogue_started(npc_id: String)
signal dialogue_ended(npc_id: String)

# Emitted when quest is triggered
signal quest_triggered(quest_id: String, npc_id: String)

# Emitted when schedule changes
signal schedule_changed(npc_id: String, location: String, activity: String)

# Emitted when relationship crosses threshold
signal relationship_threshold_crossed(npc_id: String, threshold_name: String, new_value: int)
```

### Public Methods (30+ total)

**Relationship Management:**
- `change_relationship(amount: int, reason: String) -> void`
- `set_relationship(value: int, reason: String) -> void`
- `apply_relationship_action(action_id: String) -> void`
- `get_relationship_level() -> String`
- `get_npc_reaction_to_player() -> float`

**Dialogue System:**
- `start_dialogue() -> void`
- `set_dialogue_flag(flag_name: String, value: Variant) -> void`
- `get_dialogue_flag(flag_name: String, default_value: Variant) -> Variant`
- `has_dialogue_flag(flag_name: String) -> bool`
- `trigger_quest(quest_id: String) -> void`

**Schedule System:**
- `update_schedule_for_time(game_time: String) -> void`
- `get_current_schedule_entry() -> Dictionary`
- `add_schedule_entry(time: String, location: String, activity: String) -> void`

**Save/Load:**
- `get_save_data() -> Dictionary`
- `load_save_data(data: Dictionary) -> void`

**Debug:**
- `get_debug_info() -> String`
- `print_debug_info() -> void`

### Dependencies

**Depends On:**
- **S21 Resonance Alignment** (COMPLETE ✓)
  - Access via: `ResonanceAlignment.get_alignment()`
  - Used in: Dialogue conditions, NPC reactions
  - Integration: Alignment affects dialogue branches and relationship changes

- **S03 Player** (EXISTS ✓)
  - Integration: Player interacts with NPCs
  - Interaction: Player script calls `npc.start_dialogue()` when near NPC

- **S04 Combat** (EXISTS ✓)
  - Integration: Quests can trigger combat encounters
  - Relationship changes: Helping NPC in combat increases relationship

**Depended On By:**
- **S23 Story System** (FUTURE)
  - NPCs drive story progression through quests and dialogue
  - Story flags stored in dialogue_state

- **S06 Save/Load System** (FUTURE)
  - NPC state must persist between sessions
  - Use `get_save_data()` and `load_save_data()`

---

## Testing Checklist (MCP Agent)

After scene configuration and Dialogue Manager installation, test:

### Plugin Installation ✓
```gdscript
# Verify Dialogue Manager installed
play_scene("res://tests/test_npc.tscn")
get_godot_errors()
```

- [ ] Dialogue Manager plugin appears in Project Settings → Plugins
- [ ] DialogueManager autoload registered
- [ ] `.dialogue` files show proper icon in FileSystem
- [ ] Double-clicking `elder.dialogue` opens Dialogue Editor
- [ ] No plugin errors in console

### NPC Base Functionality ✓
- [ ] Test scene runs without errors
- [ ] Elder NPC loads configuration from JSON
- [ ] Relationship value displays correctly (50/100)
- [ ] Relationship level shows "Friend"
- [ ] Alignment preference shows "Authentic"
- [ ] Current location/activity display

### Relationship System ✓
- [ ] Click "Give Gift" → relationship increases by 5
- [ ] Click "Insult Elder" → relationship decreases by 10
- [ ] Relationship clamped to 0-100 range
- [ ] Relationship label updates dynamically
- [ ] Threshold crossing signals emit (check console)
- [ ] Relationship level name changes (stranger → friend → best friend)

### Schedule System ✓
- [ ] Click "Set Time: 08:00" → location changes to "town_square"
- [ ] Activity changes to "council_duties"
- [ ] Click "Set Time: 18:00" → location changes to "tavern"
- [ ] Activity changes to "storytelling"
- [ ] Schedule change signal emits (check console)
- [ ] Labels update correctly

### Alignment Integration ✓
- [ ] ResonanceAlignment autoload accessible
- [ ] Player alignment displays in UI
- [ ] Click "More Authentic" → alignment increases
- [ ] Click "More Algorithmic" → alignment decreases
- [ ] NPC reaction changes based on player alignment
- [ ] Dialogue branches affected by alignment (test in dialogue)

### Dialogue System ✓
- [ ] Click "Talk to Elder" → dialogue window opens
- [ ] First meeting triggers "met_elder" flag
- [ ] Alignment affects dialogue options
- [ ] Relationship level affects greeting
- [ ] Dialogue choices change relationship (check after dialogue)
- [ ] Quest trigger works ("find_lost_necklace")
- [ ] Dialogue state persists between conversations
- [ ] Multiple dialogue paths accessible based on relationship

### Dialogue Manager Integration ✓
- [ ] Dialogue balloon/window appears
- [ ] Text displays correctly
- [ ] Choices appear as buttons
- [ ] Conditionals work (`if ResonanceAlignment.get_alignment() > 50`)
- [ ] Variables interpolate (`{{npc_relationship}}`)
- [ ] Mutations execute (`do npc_relationship += 5`)
- [ ] Quest triggers emit signal

### Save/Load Ready ✓
- [ ] `get_save_data()` returns complete dictionary
- [ ] `load_save_data()` restores state
- [ ] Relationship persists
- [ ] Dialogue flags persist
- [ ] Schedule state persists

### Configuration System ✓
- [ ] `npc_config.json` loads without errors
- [ ] Relationship thresholds load correctly
- [ ] Relationship actions load correctly
- [ ] NPC-specific data loads (elder, shopkeeper, etc.)
- [ ] Schedule entries parse correctly

### Debug Tools ✓
- [ ] Click "Print Debug Info" → console shows NPC state
- [ ] Debug info includes all relevant data
- [ ] No errors in debug output

### Performance ✓
```gdscript
# Run performance profiling
PerformanceProfiler.profile_system("S22")
```

- [ ] NPC system <0.1ms per frame
- [ ] Dialogue Manager overhead acceptable
- [ ] No memory leaks
- [ ] Smooth UI updates

### Integration Tests ✓
```gdscript
# Run integration tests
IntegrationTestSuite.run_all_tests()
check_quality_gates("S22")
validate_checkpoint("S22")
```

- [ ] All integration tests pass
- [ ] Quality gates pass (≥80/100)
- [ ] No warnings or errors
- [ ] Checkpoint validation passes

---

## Notes / Gotchas

### Dialogue Manager Specific
- **Plugin Installation**: MUST install Dialogue Manager plugin before testing
- **Autoload Access**: Dialogue can access autoloads like `ResonanceAlignment`
- **Variable Syntax**: Use `{{variable_name}}` for interpolation
- **Conditional Syntax**: `if condition` not `if (condition)`
- **Mutation Syntax**: `do variable = value` or `do function_call()`
- **Set Syntax**: `set function_call()` triggers game methods

### NPC System Specific
- **Relationship Scale**: 0-100 (stranger to best friend)
- **Schedule Time Format**: Must use "HH:MM" (24-hour format)
- **Dialogue File Paths**: Must use absolute `res://` paths
- **State Dictionary**: Dialogue Manager expects specific types (int, float, bool, String)
- **Singleton Access**: Use `Engine.has_singleton()` and `Engine.get_singleton()` for safety

### Integration Warnings
- **S21 Dependency**: ResonanceAlignment must be registered as autoload BEFORE testing
- **S06 Integration**: Save system must serialize dialogue_state dictionary
- **Quest System**: S23 (Story) must listen to `quest_triggered` signal
- **Time System**: Game needs global time manager to call `update_schedule_for_time()`

### GDScript 4.5 Syntax
- **class_name**: Set to `NPCBase` - don't conflict with singleton names
- **Type Hints**: All 30+ methods have complete type hints
- **String Repeat**: Uses `.repeat(60)` not `* 60`
- **Typed Arrays**: `Array[Dictionary]` for schedule
- **Signal Parameters**: All signals have typed parameters

---

## Research References

**Tier 1 Research Summary:**
- Dialogue Manager docs: https://github.com/nathanhoad/godot_dialogue_manager/tree/main/docs
- NPCScheduler algorithm: https://github.com/JakeButf/NPCScheduler
- Godot 4.5 CharacterBody2D: https://docs.godotengine.org/en/4.5/classes/class_characterbody2d.html
- Community dialogue tutorials: Evenrift, Toxigon guides

**Full research notes:** `research/s22-npc-system-research.md`

---

## Verification Evidence Required

**Tier 2 must provide:**
1. Screenshot of test scene running with UI displaying NPC info
2. Screenshot of dialogue window with elder dialogue
3. Console output showing relationship changes and signals
4. Error log output (`get_godot_errors()`) - should be empty
5. Performance profiler output
6. Integration test results

**Save to:** `evidence/S22-tier2-verification/`

---

## Completion Criteria

### System S22 is complete when:

**Tier 1 (COMPLETE ✓):**
- ✅ `npc_base.gd` complete with relationship, dialogue, schedule systems
- ✅ `npc_config.json` complete with 5 NPCs and all configuration
- ✅ `elder.dialogue` complete with alignment-based branching
- ✅ All code documented with type hints and comments
- ✅ GDScript 4.5 syntax validated
- ✅ Research documented
- ✅ Integration points documented

**Tier 2 (For MCP Agent):**
- [ ] Dialogue Manager plugin installed and working
- [ ] Test scene configured correctly
- [ ] NPC dialogue trees work with conditional branches
- [ ] Relationship system tracks interactions (0-100 scale)
- [ ] Alignment affects dialogue options (via S21 integration)
- [ ] Quest triggers work from dialogue choices
- [ ] NPC schedules change location/activity by time
- [ ] Dialogue state persists between conversations
- [ ] Integrates with S21 Alignment (dialogue branches)
- [ ] Integrates with S06 Save/Load (state persistence ready)
- [ ] Performance meets targets (<0.1ms)
- [ ] Integration tests pass
- [ ] Quality gates pass
- [ ] Checkpoint saved to Memory MCP
- [ ] COORDINATION-DASHBOARD.md updated

**Next Steps:**
- S23 Story System can use NPCs for narrative
- S06 Save/Load can persist NPC state
- Game world can have multiple NPCs with unique schedules
- Quest system can track NPC-given quests

---

**HANDOFF STATUS: READY FOR TIER 2**
**Estimated Tier 2 Time:** 3-4 hours (plugin install + scene config + testing)
**Priority:** MEDIUM (unlocks S23 Story system)
**Complexity:** MEDIUM-HIGH (requires plugin installation)

---

*Generated by: Claude Code Web*
*Date: 2025-11-18*
*Prompt: 024-s22-npc-system.md*
*System: S22 - Complex NPC System*
