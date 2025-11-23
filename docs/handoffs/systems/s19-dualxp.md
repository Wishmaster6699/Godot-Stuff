# HANDOFF: S19 - Dual XP System
**From:** Tier 1 (Claude Code Web)
**To:** Tier 2 (Godot MCP Agent)
**Date:** 2025-11-18
**Status:** READY FOR TIER 2

---

## System Overview

**Purpose:** Implement dual progression system with Combat XP (physical stats) and Knowledge XP (magical stats)
**Type:** Autoload Singleton + UI Components
**Dependencies:** S04 (Combat), S17 (Puzzles), S06 (Save/Load)

The Dual XP System splits character progression into two independent paths:
- **Combat XP**: Gained from enemy defeats, increases HP, Physical Attack, Physical Defense, Speed
- **Knowledge XP**: Gained from puzzles/lore/dialogue, increases MP, Special Attack, Special Defense, Magic Affinity

Players can specialize in one path or balance both based on playstyle.

---

## Files Created by Tier 1

### GDScript Files
- ✅ `src/systems/s19-dual-xp/xp_manager.gd` - Complete dual XP tracking system
  - Combat XP and Knowledge XP tracking
  - Independent level curves for each type
  - Stat bonus application
  - Integration methods for S04 and S17
  - Save/load support
  - Perfect rhythm combat bonus (+25%)
  - Boss XP multiplier (5x)

- ✅ `src/systems/s19-dual-xp/level_up_panel.gd` - Level-up notification UI
  - Animated level-up display
  - Shows stat increases
  - Different colors for Combat (red) vs Knowledge (blue)
  - Automatic display on level-up

### Data Files
- ✅ `src/systems/s19-dual-xp/xp_config.json` - Complete XP configuration
  - Level curves (20 levels defined)
  - Stat growth per level for both types
  - XP source values (enemies, puzzles, lore, dialogue, areas)
  - Bonus multipliers
  - UI settings
  - Integration notes

**All files validated:** Syntax ✓ | Type hints ✓ | Documentation ✓ | GDScript 4.5 ✓

---

## Godot MCP Commands for Tier 2

### Step 1: Register XPManager Autoload

**CRITICAL:** The XPManager must be registered as an autoload singleton.

Use the Godot editor or modify `project.godot`:

```ini
[autoload]
XPManager="*res://src/systems/s19-dual-xp/xp_manager.gd"
```

**Note:** The `*` prefix means the autoload is instantiated at startup.

### Step 2: Create Level-Up UI Scene

```python
# Create level-up panel scene
create_scene("res://scenes/s19-dual-xp/level_up_panel.tscn", "Panel")

# Add title label
add_node("res://scenes/s19-dual-xp/level_up_panel.tscn", "Label", "TitleLabel", ".")

# Add combat level label
add_node("res://scenes/s19-dual-xp/level_up_panel.tscn", "Label", "CombatLevelLabel", ".")

# Add knowledge level label
add_node("res://scenes/s19-dual-xp/level_up_panel.tscn", "Label", "KnowledgeLevelLabel", ".")

# Add stats container
add_node("res://scenes/s19-dual-xp/level_up_panel.tscn", "VBoxContainer", "StatsContainer", ".")

# Attach script
attach_script("res://scenes/s19-dual-xp/level_up_panel.tscn", ".", "res://src/systems/s19-dual-xp/level_up_panel.gd")

# Configure panel properties
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", ".", "custom_minimum_size", "Vector2(400, 300)")
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", ".", "position", "Vector2(460, 240)")
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", ".", "visible", false)

# Configure title label
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", "TitleLabel", "text", "LEVEL UP!")
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", "TitleLabel", "horizontal_alignment", 1)  # CENTER
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", "TitleLabel", "position", "Vector2(50, 20)")
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", "TitleLabel", "size", "Vector2(300, 40)")

# Configure combat level label
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", "CombatLevelLabel", "text", "Combat Level 5")
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", "CombatLevelLabel", "horizontal_alignment", 1)
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", "CombatLevelLabel", "position", "Vector2(50, 70)")
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", "CombatLevelLabel", "size", "Vector2(300, 30)")

# Configure knowledge level label
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", "KnowledgeLevelLabel", "text", "Knowledge Level 5")
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", "KnowledgeLevelLabel", "horizontal_alignment", 1)
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", "KnowledgeLevelLabel", "position", "Vector2(50, 70)")
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", "KnowledgeLevelLabel", "size", "Vector2(300, 30)")

# Configure stats container
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", "StatsContainer", "position", "Vector2(80, 110)")
update_property("res://scenes/s19-dual-xp/level_up_panel.tscn", "StatsContainer", "size", "Vector2(240, 150)")
```

### Step 3: Create Test Scene

```python
# Create test scene
create_scene("res://scenes/s19-dual-xp/test_dual_xp.tscn", "Node2D")

# Add control buttons
add_node("res://scenes/s19-dual-xp/test_dual_xp.tscn", "Button", "GrantCombatXPButton", ".")
add_node("res://scenes/s19-dual-xp/test_dual_xp.tscn", "Button", "GrantKnowledgeXPButton", ".")
add_node("res://scenes/s19-dual-xp/test_dual_xp.tscn", "Button", "TestCombatLevelUpButton", ".")
add_node("res://scenes/s19-dual-xp/test_dual_xp.tscn", "Button", "TestKnowledgeLevelUpButton", ".")

# Add XP display labels
add_node("res://scenes/s19-dual-xp/test_dual_xp.tscn", "Label", "CombatXPLabel", ".")
add_node("res://scenes/s19-dual-xp/test_dual_xp.tscn", "Label", "KnowledgeXPLabel", ".")

# Add level-up panel instance
add_node("res://scenes/s19-dual-xp/test_dual_xp.tscn", "Panel", "LevelUpPanel", ".", "res://scenes/s19-dual-xp/level_up_panel.tscn")

# Configure button positions and text
update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "GrantCombatXPButton", "text", "Grant Combat XP (+100)")
update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "GrantCombatXPButton", "position", "Vector2(50, 50)")
update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "GrantCombatXPButton", "size", "Vector2(200, 40)")

update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "GrantKnowledgeXPButton", "text", "Grant Knowledge XP (+100)")
update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "GrantKnowledgeXPButton", "position", "Vector2(50, 110)")
update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "GrantKnowledgeXPButton", "size", "Vector2(200, 40)")

update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "TestCombatLevelUpButton", "text", "Test Combat Level-Up UI")
update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "TestCombatLevelUpButton", "position", "Vector2(50, 170)")
update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "TestCombatLevelUpButton", "size", "Vector2(200, 40)")

update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "TestKnowledgeLevelUpButton", "text", "Test Knowledge Level-Up UI")
update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "TestKnowledgeLevelUpButton", "position", "Vector2(50, 230)")
update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "TestKnowledgeLevelUpButton", "size", "Vector2(200, 40)")

# Configure labels
update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "CombatXPLabel", "text", "Combat XP: 0/100 (Lv 1)")
update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "CombatXPLabel", "position", "Vector2(300, 80)")
update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "CombatXPLabel", "size", "Vector2(300, 30)")

update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "KnowledgeXPLabel", "text", "Knowledge XP: 0/100 (Lv 1)")
update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "KnowledgeXPLabel", "position", "Vector2(300, 140)")
update_property("res://scenes/s19-dual-xp/test_dual_xp.tscn", "KnowledgeXPLabel", "size", "Vector2(300, 30)")
```

### Step 4: Create Test Script

Create `src/systems/s19-dual-xp/test_dual_xp.gd`:

```gdscript
extends Node2D

var xp_manager: Node = null

func _ready() -> void:
	xp_manager = get_node("/root/XPManager")

	# Connect buttons
	$GrantCombatXPButton.pressed.connect(_on_grant_combat_xp)
	$GrantKnowledgeXPButton.pressed.connect(_on_grant_knowledge_xp)
	$TestCombatLevelUpButton.pressed.connect(_on_test_combat_level_up)
	$TestKnowledgeLevelUpButton.pressed.connect(_on_test_knowledge_level_up)

	# Connect XP signals
	xp_manager.xp_changed.connect(_on_xp_changed)

	# Initial display
	_update_labels()

func _on_grant_combat_xp() -> void:
	xp_manager.add_combat_xp(100, "Test")

func _on_grant_knowledge_xp() -> void:
	xp_manager.add_knowledge_xp(100, "Test")

func _on_test_combat_level_up() -> void:
	$LevelUpPanel.test_combat_level_up(xp_manager.combat_level)

func _on_test_knowledge_level_up() -> void:
	$LevelUpPanel.test_knowledge_level_up(xp_manager.knowledge_level)

func _on_xp_changed(_combat_xp: int, _knowledge_xp: int, _combat_level: int, _knowledge_level: int) -> void:
	_update_labels()

func _update_labels() -> void:
	var data: Dictionary = xp_manager.get_xp_data()
	$CombatXPLabel.text = "Combat XP: %d/%d (Lv %d)" % [data.combat_xp, data.combat_xp_required, data.combat_level]
	$KnowledgeXPLabel.text = "Knowledge XP: %d/%d (Lv %d)" % [data.knowledge_xp, data.knowledge_xp_required, data.knowledge_level]
```

Then attach the script:

```python
# Create and attach test script
attach_script("res://scenes/s19-dual-xp/test_dual_xp.tscn", ".", "res://src/systems/s19-dual-xp/test_dual_xp.gd")
```

---

## Scene Structure

### Level-Up Panel Structure
```
Panel (level_up_panel.tscn)
├── Label (TitleLabel) - "LEVEL UP!"
├── Label (CombatLevelLabel) - "Combat Level X"
├── Label (KnowledgeLevelLabel) - "Knowledge Level X"
└── VBoxContainer (StatsContainer)
    └── [Dynamically created stat labels]
```

### Test Scene Structure
```
Node2D (test_dual_xp.tscn)
├── Button (GrantCombatXPButton)
├── Button (GrantKnowledgeXPButton)
├── Button (TestCombatLevelUpButton)
├── Button (TestKnowledgeLevelUpButton)
├── Label (CombatXPLabel)
├── Label (KnowledgeXPLabel)
└── Panel (LevelUpPanel) [instanced scene]
```

---

## Integration Notes

### Integration with Combat System (S04)

To connect combat XP rewards, in the combat manager or combatant defeat handler:

```gdscript
# In combat_manager.gd or similar
func _on_enemy_defeated(enemy: Combatant) -> void:
	var xp_manager: Node = get_node("/root/XPManager")
	xp_manager.on_enemy_defeated(enemy)
	# XPManager calculates XP based on enemy.level, enemy.base_xp, etc.
```

**Required enemy properties:**
- `level: int` - Enemy level
- `base_xp: int` (optional) - Base XP value (defaults to 50 if not set)
- `difficulty_multiplier: float` (optional) - Difficulty scaling (defaults to 1.0)
- `is_boss: bool` (optional) - Boss flag for 5x XP multiplier

### Integration with Puzzle System (S17)

To connect puzzle knowledge XP:

```gdscript
# In puzzle_base.gd or puzzle manager
func _on_puzzle_solved() -> void:
	var xp_manager: Node = get_node("/root/XPManager")
	xp_manager.on_puzzle_solved(puzzle_id, reward)
	# reward Dictionary should contain "difficulty": int (1-10)
```

### Integration with Save/Load System (S06)

```gdscript
# In save manager
func save_game() -> void:
	var xp_manager: Node = get_node("/root/XPManager")
	var xp_data: Dictionary = xp_manager.get_save_data()
	save_data["xp_system"] = xp_data

func load_game(save_data: Dictionary) -> void:
	var xp_manager: Node = get_node("/root/XPManager")
	if save_data.has("xp_system"):
		xp_manager.load_save_data(save_data["xp_system"])
```

### Player Reference Setup

The XP manager needs a reference to the player's Combatant to apply stat bonuses:

```gdscript
# When player is loaded/created
var xp_manager: Node = get_node("/root/XPManager")
xp_manager.set_player_combatant(player_combatant)
```

---

## Testing Checklist for Tier 2

**Before marking complete, Tier 2 agent MUST verify:**

### Scene Configuration Tests
- [ ] XPManager autoload registered and accessible: `get_node("/root/XPManager")`
- [ ] Level-up panel scene created with all required nodes
- [ ] Test scene created with all buttons and labels
- [ ] Test scene runs without errors: `play_scene("res://scenes/s19-dual-xp/test_dual_xp.tscn")`
- [ ] No script errors in Godot output: `get_godot_errors()`

### Combat XP Tests
- [ ] Clicking "Grant Combat XP" increases combat XP value
- [ ] Combat XP label updates correctly
- [ ] Combat level-up occurs at 100 XP (level 1→2)
- [ ] Combat level-up shows red-themed level-up panel
- [ ] Stat increases displayed: Max HP +10, Physical Attack +3, Physical Defense +2, Speed +1
- [ ] Multiple level-ups work (grant 1000 XP, should reach level 4+)

### Knowledge XP Tests
- [ ] Clicking "Grant Knowledge XP" increases knowledge XP value
- [ ] Knowledge XP label updates correctly
- [ ] Knowledge level-up occurs at 100 XP (level 1→2)
- [ ] Knowledge level-up shows blue-themed level-up panel
- [ ] Stat increases displayed: Max MP +10, Special Attack +3, Special Defense +2, Magic Affinity +1
- [ ] Multiple level-ups work (grant 1000 XP, should reach level 4+)

### Dual XP Independence Tests
- [ ] Combat XP and Knowledge XP track separately
- [ ] Leveling up combat doesn't affect knowledge level
- [ ] Leveling up knowledge doesn't affect combat level
- [ ] Both XP types can be at different levels simultaneously

### Level Curve Tests
- [ ] Level 1→2: 100 XP required ✓
- [ ] Level 2→3: 250 XP required ✓
- [ ] Level 3→4: 500 XP required ✓
- [ ] Level curves follow exponential growth pattern
- [ ] XP progress percentage calculates correctly (0.0 to 1.0)

### UI Tests
- [ ] Test Combat Level-Up button shows red panel with sample stats
- [ ] Test Knowledge Level-Up button shows blue panel with sample stats
- [ ] Level-up panel fades in smoothly
- [ ] Level-up panel displays for 3 seconds
- [ ] Level-up panel fades out smoothly
- [ ] Multiple level-ups queue correctly (don't overlap)
- [ ] Stat increases formatted correctly ("Max HP +10")

### Integration Tests
- [ ] XPManager.get_save_data() returns valid Dictionary
- [ ] XPManager.load_save_data() restores XP values correctly
- [ ] XPManager.calculate_combat_xp_reward() returns correct XP values
- [ ] XPManager.calculate_puzzle_xp_reward() returns correct XP values
- [ ] Perfect rhythm bonus calculation works (+25%)
- [ ] Boss multiplier works (5x XP)

### Framework Quality Gates
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S19")`
- [ ] Quality gates passed: `check_quality_gates("S19")`
- [ ] Checkpoint validated: `validate_checkpoint("S19")`

**Expected Results:**
- All tests PASS
- No Godot errors in output
- Performance: <0.1ms per frame overhead
- Quality score: ≥80/100

---

## Known Issues & Gotchas

### Godot 4.5 Specific
- Use `get_node("/root/AutoloadName")` to access autoloads
- Tween API changed in Godot 4.x - use `create_tween()` not `Tween.new()`
- FileAccess API changed - use `FileAccess.open()` not `File.new()`
- JSON parsing uses `JSON.new()` and `json.parse()`

### System-Specific
- XP Manager must be registered as autoload BEFORE test scene runs
- Player combatant reference must be set for stat bonuses to apply
- Level-up panel uses `@onready` with fallback checks for missing nodes
- Multiple simultaneous level-ups are queued automatically

### Integration Warnings
- Combat system (S04) must emit defeated signal with enemy reference
- Puzzle system (S17) must include difficulty in reward Dictionary
- Save/load system (S06) must call get_save_data() and load_save_data()
- Stat bonuses only apply if player_combatant reference is set

---

## Completion Criteria

**System S19 is complete when:**
- ✅ XPManager autoload registered and functional
- ✅ Both XP types track independently
- ✅ Combat level-ups increase HP and physical stats
- ✅ Knowledge level-ups increase MP and special stats
- ✅ Level curves work correctly (exponential growth)
- ✅ Level-up UI displays correctly with animations
- ✅ Test scene demonstrates all functionality
- ✅ Integration methods work (combat, puzzles, save/load)
- ✅ Perfect rhythm bonus applies (+25%)
- ✅ Boss multiplier applies (5x)
- ✅ All tests pass
- ✅ Quality gates pass
- ✅ No errors in Godot output

**Next Steps:**
- S20 Evolution System can check XP levels as evolution requirements
- Combat system (S04) can connect to on_enemy_defeated()
- Puzzle system (S17) can connect to on_puzzle_solved()
- Save/Load system (S06) can integrate XP data persistence

---

## Verification Evidence Required

**Tier 2 must provide:**
1. Screenshot of test scene running with XP displays
2. Screenshot of combat level-up panel (red theme)
3. Screenshot of knowledge level-up panel (blue theme)
4. Error log output (should be empty): `get_godot_errors()`
5. Performance profiler output
6. Integration test results

**Save to:** `evidence/S19-tier2-verification/`

---

**HANDOFF STATUS: READY FOR TIER 2**
**Estimated Tier 2 Time:** 2-3 hours (scene config + testing)
**Priority:** MEDIUM (blocks S20 Evolution System)

---

*Generated by: Claude Code Web*
*Date: 2025-11-18*
*Prompt: 021-s19-dual-xp-system.md*
*Branch: claude/implement-dual-xp-system-014LQtLQmRBNZ6ZhD7vqoqeD*
