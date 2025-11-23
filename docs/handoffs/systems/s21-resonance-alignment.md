# System S21 Handoff - Resonance Alignment System

**Created by:** Claude Code Web
**Date:** 2025-11-18
**Status:** Ready for MCP Agent Configuration

---

## System Overview

**Purpose:** Track player alignment from -100 (Algorithmic) to +100 (Authentic), affecting combat effectiveness, NPC reactions, loot drops, and visual aesthetics. This is the thematic core of the game - the duality between authentic human creativity and algorithmic generation.

**Type:** Autoload Singleton
**Dependencies:** S04 (Combat), S11 (Enemy AI), S12 (Monsters)

---

## Files Created (Tier 1 Complete)

### GDScript Files
- ✅ `src/systems/s21-resonance-alignment/resonance_alignment.gd` - Complete alignment manager
  - Tracks alignment from -100 to +100
  - Action-based alignment shifts
  - Combat effectiveness modifiers (+20% vs opposite type)
  - Visual theme system (organic vs digital)
  - Loot drop modifiers
  - NPC reaction system (ready for S22)
  - Save/load integration (ready for S06)
  - Comprehensive debug tools

### Data Files
- ✅ `data/alignment_config.json` - Complete alignment configuration
  - 35+ predefined action shifts
  - Threshold definitions
  - Combat modifier formulas
  - Visual theme mappings (authentic, algorithmic, neutral)
  - Loot drop multipliers
  - NPC reaction rules
  - Ending requirements
  - Enemy alignment mappings

### Research
- ✅ `research/s21-resonance-alignment-research.md` - Complete research findings

**All files validated:** Syntax ✓ | Type hints ✓ | Documentation ✓ | GDScript 4.5 ✓

---

## Godot MCP Commands for Tier 2

### Step 1: Register Autoload

**CRITICAL:** The alignment system must be registered as an autoload singleton.

Open `project.godot` and add (or use GDAI autoload registration if available):

```ini
[autoload]
ResonanceAlignment="*res://src/systems/s21-resonance-alignment/resonance_alignment.gd"
```

**Note:** The autoload name is `ResonanceAlignment` (not `ResonanceAlignmentImpl`). Access globally via `ResonanceAlignment` throughout the game.

### Step 2: Create Test Scene

Create a test scene to verify alignment shifts, combat modifiers, and visual feedback.

```gdscript
# Create test scene
create_scene("res://tests/test_alignment.tscn", "Node2D")

# Add UI elements for displaying alignment
add_node("res://tests/test_alignment.tscn", "VBoxContainer", "UIContainer")
add_node("UIContainer", "Label", "AlignmentValue")
add_node("UIContainer", "Label", "AlignmentType")
add_node("UIContainer", "Label", "CombatModifier")
add_node("UIContainer", "HSeparator", "Separator1")

# Add action buttons
add_node("UIContainer", "Label", "ActionsLabel")
add_node("UIContainer", "HBoxContainer", "AuthenticActions")
add_node("AuthenticActions", "Button", "HelpNPC")
add_node("AuthenticActions", "Button", "CreativePuzzle")
add_node("AuthenticActions", "Button", "BefriendAuthentic")

add_node("UIContainer", "HBoxContainer", "AlgorithmicActions")
add_node("AlgorithmicActions", "Button", "UseExploit")
add_node("AlgorithmicActions", "Button", "BruteForce")
add_node("AlgorithmicActions", "Button", "BefriendAlgorithmic")

add_node("UIContainer", "HSeparator", "Separator2")
add_node("UIContainer", "Button", "ResetAlignment")
add_node("UIContainer", "Button", "PrintDebugInfo")

# Add visual feedback element
add_node("res://tests/test_alignment.tscn", "ColorRect", "VisualFeedback")
add_node("res://tests/test_alignment.tscn", "Label", "HistoryLabel")

# Configure properties
update_property("UIContainer", "position", Vector2(20, 20))

update_property("AlignmentValue", "text", "Alignment: 0.0")
update_property("AlignmentType", "text", "Type: neutral")
update_property("CombatModifier", "text", "Combat Modifier: 1.0x")
update_property("ActionsLabel", "text", "Actions:")

update_property("HelpNPC", "text", "+5 Help NPC (Authentic)")
update_property("CreativePuzzle", "text", "+3 Creative Puzzle")
update_property("BefriendAuthentic", "text", "+7 Befriend Authentic")

update_property("UseExploit", "text", "-10 Use Exploit")
update_property("BruteForce", "text", "-3 Brute Force")
update_property("BefriendAlgorithmic", "text", "-7 Befriend Algorithmic")

update_property("ResetAlignment", "text", "Reset to Neutral")
update_property("PrintDebugInfo", "text", "Print Debug Info")

update_property("VisualFeedback", "position", Vector2(400, 20))
update_property("VisualFeedback", "size", Vector2(300, 300))
update_property("VisualFeedback", "color", Color(1.0, 1.0, 1.0, 1.0))

update_property("HistoryLabel", "position", Vector2(20, 350))
update_property("HistoryLabel", "text", "History: (none)")
```

### Step 3: Create Test Script

Create a test script that connects to the alignment system and handles UI updates.

```gdscript
create_script("res://tests/test_alignment_scene.gd", """
extends Node2D

# UI References
@onready var alignment_value_label: Label = $UIContainer/AlignmentValue
@onready var alignment_type_label: Label = $UIContainer/AlignmentType
@onready var combat_modifier_label: Label = $UIContainer/CombatModifier
@onready var visual_feedback: ColorRect = $VisualFeedback
@onready var history_label: Label = $HistoryLabel

# Action buttons
@onready var help_npc_btn: Button = $UIContainer/AuthenticActions/HelpNPC
@onready var creative_puzzle_btn: Button = $UIContainer/AuthenticActions/CreativePuzzle
@onready var befriend_auth_btn: Button = $UIContainer/AuthenticActions/BefriendAuthentic
@onready var use_exploit_btn: Button = $UIContainer/AlgorithmicActions/UseExploit
@onready var brute_force_btn: Button = $UIContainer/AlgorithmicActions/BruteForce
@onready var befriend_algo_btn: Button = $UIContainer/AlgorithmicActions/BefriendAlgorithmic
@onready var reset_btn: Button = $UIContainer/ResetAlignment
@onready var debug_btn: Button = $UIContainer/PrintDebugInfo


func _ready() -> void:
	# Connect to alignment system signals
	ResonanceAlignment.alignment_changed.connect(_on_alignment_changed)
	ResonanceAlignment.alignment_threshold_crossed.connect(_on_threshold_crossed)
	ResonanceAlignment.visual_theme_changed.connect(_on_visual_theme_changed)

	# Connect button signals
	help_npc_btn.pressed.connect(_on_help_npc)
	creative_puzzle_btn.pressed.connect(_on_creative_puzzle)
	befriend_auth_btn.pressed.connect(_on_befriend_authentic)
	use_exploit_btn.pressed.connect(_on_use_exploit)
	brute_force_btn.pressed.connect(_on_brute_force)
	befriend_algo_btn.pressed.connect(_on_befriend_algorithmic)
	reset_btn.pressed.connect(_on_reset)
	debug_btn.pressed.connect(_on_print_debug)

	# Initial UI update
	_update_ui()


func _on_alignment_changed(new_alignment: float, reason: String) -> void:
	_update_ui()
	print(\"Alignment changed: \", new_alignment, \" (\", reason, \")\")


func _on_threshold_crossed(threshold_name: String, new_alignment: float) -> void:
	print(\"Threshold crossed: \", threshold_name, \" at \", new_alignment)


func _on_visual_theme_changed(theme_data: Dictionary) -> void:
	print(\"Visual theme changed: \", theme_data)
	_update_visual_feedback()


func _update_ui() -> void:
	var alignment := ResonanceAlignment.get_alignment()
	var alignment_type := ResonanceAlignment.get_alignment_type()
	var combat_mod := ResonanceAlignment.get_combat_modifier(\"algorithmic\")

	alignment_value_label.text = \"Alignment: %.1f\" % alignment
	alignment_type_label.text = \"Type: %s\" % alignment_type
	combat_modifier_label.text = \"Combat Modifier (vs Algorithmic): %.2fx\" % combat_mod

	_update_visual_feedback()
	_update_history()


func _update_visual_feedback() -> void:
	var theme_color := ResonanceAlignment.get_theme_color()
	visual_feedback.color = theme_color


func _update_history() -> void:
	var history_string := ResonanceAlignment.get_alignment_history_string(5)
	history_label.text = history_string


# Button handlers
func _on_help_npc() -> void:
	ResonanceAlignment.shift_alignment_by_action(\"help_npc_authentic\")


func _on_creative_puzzle() -> void:
	ResonanceAlignment.shift_alignment_by_action(\"solve_puzzle_creatively\")


func _on_befriend_authentic() -> void:
	ResonanceAlignment.shift_alignment_by_action(\"befriend_authentic_npc\")


func _on_use_exploit() -> void:
	ResonanceAlignment.shift_alignment_by_action(\"use_algorithm_exploit\")


func _on_brute_force() -> void:
	ResonanceAlignment.shift_alignment_by_action(\"use_brute_force\")


func _on_befriend_algorithmic() -> void:
	ResonanceAlignment.shift_alignment_by_action(\"befriend_algorithm_npc\")


func _on_reset() -> void:
	ResonanceAlignment.reset_alignment()


func _on_print_debug() -> void:
	ResonanceAlignment.print_debug_info()
""")

# Attach script to test scene
attach_script("res://tests/test_alignment.tscn", "Node2D", "res://tests/test_alignment_scene.gd")
```

---

## Node Hierarchies

### Test Scene Structure
```
Node2D (test_alignment.tscn)
├── UIContainer (VBoxContainer)
│   ├── AlignmentValue (Label)
│   ├── AlignmentType (Label)
│   ├── CombatModifier (Label)
│   ├── Separator1 (HSeparator)
│   ├── ActionsLabel (Label)
│   ├── AuthenticActions (HBoxContainer)
│   │   ├── HelpNPC (Button)
│   │   ├── CreativePuzzle (Button)
│   │   └── BefriendAuthentic (Button)
│   ├── AlgorithmicActions (HBoxContainer)
│   │   ├── UseExploit (Button)
│   │   ├── BruteForce (Button)
│   │   └── BefriendAlgorithmic (Button)
│   ├── Separator2 (HSeparator)
│   ├── ResetAlignment (Button)
│   └── PrintDebugInfo (Button)
├── VisualFeedback (ColorRect)
├── HistoryLabel (Label)
└── [Script: test_alignment_scene.gd]
```

---

## Integration Points

### Signals Exposed

```gdscript
# Emitted when alignment value changes
signal alignment_changed(new_alignment: float, reason: String)

# Emitted when alignment crosses a major threshold
signal alignment_threshold_crossed(threshold_name: String, new_alignment: float)

# Emitted when visual theme should update
signal visual_theme_changed(theme_data: Dictionary)
```

### Public Methods

```gdscript
# Alignment Modification
ResonanceAlignment.shift_alignment(amount: float, reason: String) -> void
ResonanceAlignment.shift_alignment_by_action(action_id: String) -> void
ResonanceAlignment.set_alignment(value: float, reason: String = "direct_set") -> void
ResonanceAlignment.reset_alignment() -> void

# Alignment Queries
ResonanceAlignment.get_alignment() -> float  # -100 to +100
ResonanceAlignment.get_alignment_type() -> String  # "authentic", "neutral", "algorithmic"
ResonanceAlignment.get_normalized_alignment() -> float  # -1.0 to +1.0
ResonanceAlignment.is_authentic_aligned() -> bool
ResonanceAlignment.is_algorithmic_aligned() -> bool
ResonanceAlignment.is_neutral() -> bool

# Combat Integration
ResonanceAlignment.get_combat_modifier(enemy_alignment: String) -> float
ResonanceAlignment.get_defensive_modifier(attacker_alignment: String) -> float

# Visual Theme
ResonanceAlignment.get_visual_theme() -> Dictionary
ResonanceAlignment.get_theme_color() -> Color

# Loot System
ResonanceAlignment.get_loot_category() -> String  # "organic", "digital", "neutral"
ResonanceAlignment.get_loot_drop_multiplier(loot_alignment: String) -> float

# NPC Reactions (Ready for S22)
ResonanceAlignment.get_npc_reaction_modifier(npc_alignment_preference: String) -> float

# Save/Load (Ready for S06)
ResonanceAlignment.get_save_data() -> Dictionary
ResonanceAlignment.load_save_data(data: Dictionary) -> void

# Debug
ResonanceAlignment.get_debug_info() -> String
ResonanceAlignment.print_debug_info() -> void
ResonanceAlignment.get_alignment_history_string(count: int = 10) -> String
```

### Dependencies

**Depends on:**
- S04 (Combat): Combat effectiveness modifiers integrate with Combatant damage calculations
- S11 (Enemy AI): Enemy AI types mapped to alignments
- S12 (Monsters): Monster types and loot tables use alignment

**Depended on by:**
- S22 (NPC Dialogue): NPCs react based on player alignment
- S23 (Story System): Story endings determined by alignment
- S06 (Save/Load): Alignment persists between sessions
- S13 (Vibe Bar): Could visualize alignment as secondary meter

---

## Integration Examples

### S04 Combat Integration

In `combatant.gd` or `combat_manager.gd`, modify damage calculation:

```gdscript
func calculate_damage(attacker: Combatant, defender: Combatant, move_power: int) -> int:
	# ... existing damage calculation ...

	# Apply alignment modifier if ResonanceAlignment exists
	if has_node("/root/ResonanceAlignment"):
		var defender_alignment := _get_enemy_alignment_type(defender)
		var alignment_modifier := ResonanceAlignment.get_combat_modifier(defender_alignment)
		final_damage = int(final_damage * alignment_modifier)

	return final_damage

func _get_enemy_alignment_type(enemy: Combatant) -> String:
	# Check enemy's AI behavior or monster type
	if enemy.has_method("get_alignment_type"):
		return enemy.get_alignment_type()
	return "neutral"
```

### S11 Enemy AI Integration

In `enemy_base.gd`, add alignment type:

```gdscript
## Get alignment type based on AI behavior
func get_alignment_type() -> String:
	match enemy_type:
		EnemyType.AGGRESSIVE:
			return "algorithmic"
		EnemyType.DEFENSIVE:
			return "authentic"
		EnemyType.RANGED:
			return "algorithmic"
		EnemyType.SWARM:
			return "neutral"
	return "neutral"
```

### S12 Monster Database Integration

In monster JSON data, add `alignment` field:

```json
{
  "id": "001_sparkle",
  "name": "Sparkle",
  "types": ["electric"],
  "alignment": "algorithmic",
  "loot_table": {
    "organic": ["herb"],
    "digital": ["circuit", "data_shard"],
    "alignment_aware": true
  }
}
```

When dropping loot, use alignment multiplier:

```gdscript
func calculate_loot_drop(monster: MonsterResource) -> Array:
	var loot_items: Array = []

	for item_id in monster.loot_table.get("digital", []):
		var drop_multiplier := ResonanceAlignment.get_loot_drop_multiplier("digital")
		var drop_chance := base_drop_chance * drop_multiplier

		if randf() < drop_chance:
			loot_items.append(item_id)

	return loot_items
```

---

## Testing Checklist (MCP Agent)

After scene configuration, test with:

```gdscript
# Play test scene
play_scene("res://tests/test_alignment.tscn")

# Check for errors
get_godot_errors()
```

**Verify:**

- [ ] Autoload registered and accessible globally (`ResonanceAlignment`)
- [ ] Test scene runs without errors
- [ ] Alignment starts at 0.0 (neutral)
- [ ] Alignment shifts correctly when buttons pressed
- [ ] Alignment clamped to -100 to +100 range
- [ ] Alignment type changes at thresholds (-50, +50)
- [ ] `alignment_changed` signal emits on every shift
- [ ] `alignment_threshold_crossed` signal emits when crossing -50 or +50
- [ ] Visual feedback (ColorRect) changes color based on alignment
  - Authentic: Orange (#FF8C42)
  - Algorithmic: Blue (#00BFFF)
  - Neutral: White (#FFFFFF)
- [ ] Combat modifier calculates correctly
  - Authentic player vs Algorithmic enemy: 1.2x damage
  - Algorithmic player vs Authentic enemy: 1.2x damage
  - Neutral or same alignment: 1.0x damage
- [ ] Loot category returns correctly
  - Authentic: "organic"
  - Algorithmic: "digital"
  - Neutral: "neutral"
- [ ] NPC reaction modifiers calculate correctly
- [ ] Debug info prints comprehensive alignment state
- [ ] History tracking works (last 100 entries)
- [ ] Save/load methods work (test manually or with S06)
- [ ] Configuration loads from `alignment_config.json`
- [ ] No errors or warnings in console

**Expected Results:**
- All manual tests pass
- No GDScript errors
- Alignment system ready for integration with other systems

---

## Performance Verification

Run performance profiling:

```gdscript
# In Godot console or profiler
PerformanceProfiler.profile_system("S21")
```

**Expected Performance:**
- Alignment shift: <0.01ms per call
- Combat modifier lookup: <0.01ms per call
- Visual theme query: <0.01ms per call
- No memory leaks over 1000 alignment shifts

---

## Notes / Gotchas

### GDScript 4.5 Specifics
- ✅ Uses `.repeat()` for string repetition (not `*` operator)
- ✅ `class_name ResonanceAlignmentImpl` declared (avoids conflict with autoload name)
- ✅ All type hints present
- ✅ Signals use `.emit()` method
- ✅ Uses `FileAccess.open()` (not `File.new()` from Godot 3.x)
- ✅ Uses `Time.get_ticks_msec()` (not `OS.get_ticks_msec()`)

### Alignment Scale
- -100 to -50: Strong Algorithmic
- -50 to +50: Neutral
- +50 to +100: Strong Authentic
- 0: Perfect neutral balance

### Visual Language
- **Authentic**: Warm colors (orange), organic shapes, hand-drawn UI
- **Algorithmic**: Cool colors (blue), geometric shapes, digital UI
- **Neutral**: Balanced, standard aesthetics

### Combat Modifiers
- +20% damage vs opposite alignment type
- No bonus vs same or neutral alignment
- Defensive modifier: +20% damage taken from opposite alignment

### Thematic Core
This system represents the game's central theme: the tension between authentic human creativity and algorithmic generation. Every player action should consider how it affects this balance.

### Integration Ready For
- **S22 NPCs**: `get_npc_reaction_modifier()` ready for dialogue branching
- **S23 Story**: Ending requirements defined in config JSON
- **S06 Save/Load**: `get_save_data()` and `load_save_data()` ready
- **S13 Vibe Bar**: Could visualize alignment as secondary meter

### Known Limitations
- Alignment is global (single value for entire game, not per-faction)
- No time-based decay (alignment stays until changed by actions)
- Combat modifiers are fixed at +20% (may need balancing)

---

## Completion Criteria

**System S21 is complete when:**
- ✅ Autoload registered in project.godot
- ✅ Test scene runs without errors
- ✅ All alignment shifts work correctly
- ✅ Threshold crossings trigger signals
- ✅ Visual theme changes reflect alignment
- ✅ Combat modifiers calculate correctly
- ✅ Loot drop multipliers work
- ✅ NPC reaction system ready
- ✅ Save/load integration ready
- ✅ Configuration loads from JSON
- ✅ Performance meets targets (<0.01ms per operation)
- ✅ No errors or warnings in console
- ✅ Integration points documented for dependent systems

**Next Steps:**
- S22 NPC System can use alignment for dialogue branches
- S23 Story System can check alignment for endings
- S04 Combat can integrate alignment modifiers
- S11 Enemy AI can assign alignment types
- S12 Monster Database can use alignment-aware loot

---

**HANDOFF STATUS: READY FOR TIER 2**
**Estimated Tier 2 Time:** 1-2 hours (autoload registration + testing)
**Priority:** MEDIUM (Wave 2 - parallel with S20)

---

*Generated by: Claude Code Web*
*Date: 2025-11-18*
*Prompt: 023-s21-resonance-alignment.md*
