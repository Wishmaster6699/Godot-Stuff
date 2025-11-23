# System S23 Handoff - Player Progression/Story System

**Created by:** Claude Code Web
**Date:** 2025-11-18
**Status:** Ready for MCP Agent Configuration

---

## Files Created (Tier 1 Complete)

### GDScript Files
- `res://story/story_manager.gd` - Complete story manager implementation with:
  - Story flag tracking system
  - Chapter progression (5 chapters)
  - Branching story paths (Authentic, Neutral, Algorithm)
  - Ending determination logic based on alignment + NPC relationships
  - Choice system with alignment shifts and flag setting
  - Integration with S21 (ResonanceAlignment) for alignment tracking
  - Integration with S22 (NPC system - when available) for relationship tracking
  - Save/Load integration with S06 (SaveManager)
  - Type hints, documentation, and error handling throughout

### Data Files
- `res://data/story_config.json` - Complete story configuration with:
  - 5 chapters with branching points
  - 10 endings (4 standard, 4 hidden, 2 secret)
  - 17 story choices with alignment shifts and flag effects
  - 4 hidden paths with unlock requirements
  - All story data configurable from JSON (no hardcoded values)

---

## Scene Configuration Needed (Tier 2 - MCP Agent Tasks)

### Scene 1: `res://tests/test_story.tscn`

Test scene for story progression system with UI elements to test choices, flags, and ending determination.

**MCP Agent Commands:**

```gdscript
# 1. Create test scene
create_scene("res://tests/test_story.tscn", "Node2D", "TestStory")

# 2. Add test script
attach_script("TestStory", "res://tests/test_story_script.gd")

# 3. Add UI elements for displaying story state
add_node("TestStory", "VBoxContainer", "StoryInfo")
update_property("TestStory/StoryInfo", "position", Vector2(10, 10))
update_property("TestStory/StoryInfo", "custom_minimum_size", Vector2(800, 200))

add_node("TestStory/StoryInfo", "Label", "TitleLabel")
update_property("TestStory/StoryInfo/TitleLabel", "text", "=== STORY MANAGER TEST ===")
update_property("TestStory/StoryInfo/TitleLabel", "horizontal_alignment", 1)

add_node("TestStory/StoryInfo", "Label", "CurrentChapter")
update_property("TestStory/StoryInfo/CurrentChapter", "text", "Chapter: 1 / 5")

add_node("TestStory/StoryInfo", "Label", "StoryBranch")
update_property("TestStory/StoryInfo/StoryBranch", "text", "Branch: neutral")

add_node("TestStory/StoryInfo", "Label", "CurrentAlignment")
update_property("TestStory/StoryInfo/CurrentAlignment", "text", "Alignment: 0.0")

add_node("TestStory/StoryInfo", "Label", "AvgRelationship")
update_property("TestStory/StoryInfo/AvgRelationship", "text", "Avg Relationship: 0.0")

add_node("TestStory/StoryInfo", "Label", "StoryFlags")
update_property("TestStory/StoryInfo/StoryFlags", "text", "Flags: 0 set")

add_node("TestStory/StoryInfo", "Label", "EndingPreview")
update_property("TestStory/StoryInfo/EndingPreview", "text", "Predicted Ending: neutral_good")

# 4. Add choice buttons container
add_node("TestStory", "VBoxContainer", "StoryChoices")
update_property("TestStory/StoryChoices", "position", Vector2(10, 230))
update_property("TestStory/StoryChoices", "custom_minimum_size", Vector2(800, 400))

add_node("TestStory/StoryChoices", "Label", "ChoicesTitle")
update_property("TestStory/StoryChoices/ChoicesTitle", "text", "=== STORY CHOICES ===")

# Chapter 1 choices
add_node("TestStory/StoryChoices", "Button", "HelpVillageBtn")
update_property("TestStory/StoryChoices/HelpVillageBtn", "text", "Help Village (Authentic +10)")
update_property("TestStory/StoryChoices/HelpVillageBtn", "custom_minimum_size", Vector2(0, 40))

add_node("TestStory/StoryChoices", "Button", "ConfrontElderBtn")
update_property("TestStory/StoryChoices/ConfrontElderBtn", "text", "Confront Elder (Algorithm -10)")
update_property("TestStory/StoryChoices/ConfrontElderBtn", "custom_minimum_size", Vector2(0, 40))

add_node("TestStory/StoryChoices", "Button", "DiscoverSecretBtn")
update_property("TestStory/StoryChoices/DiscoverSecretBtn", "text", "Discover Secret (Authentic +5)")
update_property("TestStory/StoryChoices/DiscoverSecretBtn", "custom_minimum_size", Vector2(0, 40))

# Chapter 2 choices
add_node("TestStory/StoryChoices", "Button", "JoinAuthenticBtn")
update_property("TestStory/StoryChoices/JoinAuthenticBtn", "text", "Join Authentic Faction (+15)")
update_property("TestStory/StoryChoices/JoinAuthenticBtn", "custom_minimum_size", Vector2(0, 40))

add_node("TestStory/StoryChoices", "Button", "JoinAlgorithmBtn")
update_property("TestStory/StoryChoices/JoinAlgorithmBtn", "text", "Join Algorithm Faction (-15)")
update_property("TestStory/StoryChoices/JoinAlgorithmBtn", "custom_minimum_size", Vector2(0, 40))

add_node("TestStory/StoryChoices", "Button", "StayNeutralBtn")
update_property("TestStory/StoryChoices/StayNeutralBtn", "text", "Stay Neutral (0)")
update_property("TestStory/StoryChoices/StayNeutralBtn", "custom_minimum_size", Vector2(0, 40))

# Additional test buttons
add_node("TestStory/StoryChoices", "HSeparator", "Separator1")

add_node("TestStory/StoryChoices", "Button", "HelpAllNPCsBtn")
update_property("TestStory/StoryChoices/HelpAllNPCsBtn", "text", "Help All NPCs (for hidden ending)")
update_property("TestStory/StoryChoices/HelpAllNPCsBtn", "custom_minimum_size", Vector2(0, 40))

# 5. Add control buttons container
add_node("TestStory", "VBoxContainer", "ControlButtons")
update_property("TestStory/ControlButtons", "position", Vector2(10, 650))
update_property("TestStory/ControlButtons", "custom_minimum_size", Vector2(800, 150))

add_node("TestStory/ControlButtons", "Label", "ControlsTitle")
update_property("TestStory/ControlButtons/ControlsTitle", "text", "=== CONTROLS ===")

add_node("TestStory/ControlButtons", "HBoxContainer", "ControlRow")

add_node("TestStory/ControlButtons/ControlRow", "Button", "AdvanceChapterBtn")
update_property("TestStory/ControlButtons/ControlRow/AdvanceChapterBtn", "text", "Advance Chapter")
update_property("TestStory/ControlButtons/ControlRow/AdvanceChapterBtn", "custom_minimum_size", Vector2(150, 40))

add_node("TestStory/ControlButtons/ControlRow", "Button", "CalculateEndingBtn")
update_property("TestStory/ControlButtons/ControlRow/CalculateEndingBtn", "text", "Calculate Ending")
update_property("TestStory/ControlButtons/ControlRow/CalculateEndingBtn", "custom_minimum_size", Vector2(150, 40))

add_node("TestStory/ControlButtons/ControlRow", "Button", "PrintDebugBtn")
update_property("TestStory/ControlButtons/ControlRow/PrintDebugBtn", "text", "Print Debug Info")
update_property("TestStory/ControlButtons/ControlRow/PrintDebugBtn", "custom_minimum_size", Vector2(150, 40))

add_node("TestStory/ControlButtons/ControlRow", "Button", "ResetBtn")
update_property("TestStory/ControlButtons/ControlRow/ResetBtn", "text", "Reset Story")
update_property("TestStory/ControlButtons/ControlRow/ResetBtn", "custom_minimum_size", Vector2(150, 40))
```

**Node Hierarchy:**
```
TestStory (Node2D)
├── StoryInfo (VBoxContainer)
│   ├── TitleLabel (Label)
│   ├── CurrentChapter (Label)
│   ├── StoryBranch (Label)
│   ├── CurrentAlignment (Label)
│   ├── AvgRelationship (Label)
│   ├── StoryFlags (Label)
│   └── EndingPreview (Label)
├── StoryChoices (VBoxContainer)
│   ├── ChoicesTitle (Label)
│   ├── HelpVillageBtn (Button)
│   ├── ConfrontElderBtn (Button)
│   ├── DiscoverSecretBtn (Button)
│   ├── JoinAuthenticBtn (Button)
│   ├── JoinAlgorithmBtn (Button)
│   ├── StayNeutralBtn (Button)
│   ├── Separator1 (HSeparator)
│   └── HelpAllNPCsBtn (Button)
└── ControlButtons (VBoxContainer)
    ├── ControlsTitle (Label)
    └── ControlRow (HBoxContainer)
        ├── AdvanceChapterBtn (Button)
        ├── CalculateEndingBtn (Button)
        ├── PrintDebugBtn (Button)
        └── ResetBtn (Button)
```

### Test Script: `res://tests/test_story_script.gd`

The MCP agent should create this script file:

```gdscript
# Test script for Story Manager
extends Node2D

var story_manager: Node = null

func _ready() -> void:
	# Get StoryManager
	story_manager = get_node_or_null("/root/StoryManager")
	if story_manager == null:
		push_error("StoryManager not found - ensure it's set up as autoload")
		return

	# Connect signals
	if story_manager.has_signal("story_flag_set"):
		story_manager.story_flag_set.connect(_on_story_flag_set)
	if story_manager.has_signal("chapter_complete"):
		story_manager.chapter_complete.connect(_on_chapter_complete)
	if story_manager.has_signal("ending_reached"):
		story_manager.ending_reached.connect(_on_ending_reached)
	if story_manager.has_signal("branch_changed"):
		story_manager.branch_changed.connect(_on_branch_changed)

	# Connect buttons
	$StoryChoices/HelpVillageBtn.pressed.connect(func(): make_choice("help_village"))
	$StoryChoices/ConfrontElderBtn.pressed.connect(func(): make_choice("confront_elder"))
	$StoryChoices/DiscoverSecretBtn.pressed.connect(func(): make_choice("discover_secret"))
	$StoryChoices/JoinAuthenticBtn.pressed.connect(func(): make_choice("join_authentic"))
	$StoryChoices/JoinAlgorithmBtn.pressed.connect(func(): make_choice("join_algorithm"))
	$StoryChoices/StayNeutralBtn.pressed.connect(func(): make_choice("stay_neutral"))
	$StoryChoices/HelpAllNPCsBtn.pressed.connect(func(): make_choice("help_all_npcs"))

	$ControlButtons/ControlRow/AdvanceChapterBtn.pressed.connect(_on_advance_chapter)
	$ControlButtons/ControlRow/CalculateEndingBtn.pressed.connect(_on_calculate_ending)
	$ControlButtons/ControlRow/PrintDebugBtn.pressed.connect(_on_print_debug)
	$ControlButtons/ControlRow/ResetBtn.pressed.connect(_on_reset_story)

	# Initial update
	update_display()

func make_choice(choice_id: String) -> void:
	if story_manager != null and story_manager.has_method("make_story_choice"):
		story_manager.make_story_choice(choice_id)
		update_display()

func _on_advance_chapter() -> void:
	if story_manager != null and story_manager.has_method("advance_chapter"):
		story_manager.advance_chapter()
		update_display()

func _on_calculate_ending() -> void:
	if story_manager != null and story_manager.has_method("determine_ending"):
		var ending: String = story_manager.determine_ending()
		print("═".repeat(60))
		print("CALCULATED ENDING: ", ending)
		if story_manager.has_method("get_ending_data"):
			var ending_data: Dictionary = story_manager.get_ending_data(ending)
			print("Name: ", ending_data.get("name", "Unknown"))
			print("Description: ", ending_data.get("description", "No description"))
		print("═".repeat(60))

func _on_print_debug() -> void:
	if story_manager != null and story_manager.has_method("print_debug_info"):
		story_manager.print_debug_info()

func _on_reset_story() -> void:
	# Reset alignment
	var alignment_system: Node = get_node_or_null("/root/ResonanceAlignment")
	if alignment_system != null and alignment_system.has_method("reset_alignment"):
		alignment_system.reset_alignment()

	# Reload scene to reset story
	get_tree().reload_current_scene()

func update_display() -> void:
	if story_manager == null:
		return

	# Get current state
	var chapter: int = story_manager.current_chapter if "current_chapter" in story_manager else 0
	var branch: String = story_manager.story_branch if "story_branch" in story_manager else "unknown"
	var flags: Array = story_manager.story_flags if "story_flags" in story_manager else []

	# Get alignment from S21
	var alignment: float = 0.0
	var alignment_system: Node = get_node_or_null("/root/ResonanceAlignment")
	if alignment_system != null and alignment_system.has_method("get_alignment"):
		alignment = alignment_system.get_alignment()

	# Get predicted ending
	var ending: String = "unknown"
	if story_manager.has_method("determine_ending"):
		ending = story_manager.determine_ending()

	# Update labels
	$StoryInfo/CurrentChapter.text = "Chapter: %d / 5" % chapter
	$StoryInfo/StoryBranch.text = "Branch: %s" % branch
	$StoryInfo/CurrentAlignment.text = "Alignment: %.1f" % alignment
	$StoryInfo/AvgRelationship.text = "Avg Relationship: %.1f (estimated)"
	$StoryInfo/StoryFlags.text = "Flags: %d set (%s)" % [flags.size(), str(flags)]
	$StoryInfo/EndingPreview.text = "Predicted Ending: %s" % ending

# Signal handlers
func _on_story_flag_set(flag: String) -> void:
	print("Story flag set: ", flag)

func _on_chapter_complete(chapter_id: int) -> void:
	print("Chapter complete: ", chapter_id)

func _on_ending_reached(ending_type: String) -> void:
	print("Ending reached: ", ending_type)

func _on_branch_changed(new_branch: String) -> void:
	print("Branch changed to: ", new_branch)
```

**Create this script with:**
```gdscript
create_script("res://tests/test_story_script.gd", [test script content above])
```

---

## Autoload Configuration

**CRITICAL:** StoryManager must be configured as an autoload singleton.

**MCP Agent: Add to `project.godot`:**

If not already present, add the following to the autoload section:

```ini
[autoload]
StoryManager="*res://story/story_manager.gd"
```

You may need to use the editor to add this autoload:
1. Project -> Project Settings -> Autoload tab
2. Set path: `res://story/story_manager.gd`
3. Set name: `StoryManager`
4. Enable the node

---

## Integration Points

### Signals Exposed:
- `story_flag_set(flag: String)` - Emitted when story flag is set
- `chapter_complete(chapter_id: int)` - Emitted when chapter completes
- `ending_reached(ending_type: String)` - Emitted when ending is reached
- `branch_changed(new_branch: String)` - Emitted when story branch changes
- `choice_made(choice_id: String, branch: String)` - Emitted when story choice is made

### Public Methods:
- `set_story_flag(flag: String)` - Set a story flag
- `has_story_flag(flag: String) -> bool` - Check if flag is set
- `get_story_flags() -> Array[String]` - Get all story flags
- `make_story_choice(choice_id: String)` - Make a story choice
- `determine_ending() -> String` - Calculate ending based on alignment and relationships
- `trigger_ending(ending_type: String)` - Trigger an ending sequence
- `advance_chapter()` - Move to next chapter
- `get_current_chapter() -> int` - Get current chapter number
- `get_story_branch() -> String` - Get current story branch
- `save_state() -> Dictionary` - Get save data (for S06 integration)
- `load_state(data: Dictionary)` - Load save data (for S06 integration)
- `get_debug_info() -> String` - Get debug information
- `print_debug_info()` - Print debug information to console

### Dependencies:
- **Depends on:**
  - S21 (ResonanceAlignment) - For alignment tracking ✓ Available
  - S22 (NPC System) - For relationship tracking (fallback provided if not available)
  - S04 (Combat) - For combat story events (optional integration)
  - S06 (Save/Load) - For story persistence ✓ Available

- **Depended on by:** None (final story system)

### Integration with S21 (ResonanceAlignment):
- Story choices automatically call `ResonanceAlignment.shift_alignment()` with configured shift values
- Ending determination uses `ResonanceAlignment.get_alignment()` to check alignment thresholds
- Connection established automatically in `_ready()` via autoload reference

### Integration with S22 (NPC System - When Available):
- Ending determination will call `NPCManager.get_average_relationship()` when S22 is implemented
- Currently uses fallback estimation based on story flags count
- NPC system integration is prepared but not required for basic functionality

### Integration with S06 (Save/Load):
- StoryManager implements `save_state()` and `load_state()` methods
- To enable persistence, call: `SaveManager.register_saveable(StoryManager, "story")`
- Saves: story_flags, current_chapter, story_branch, choice_history (last 10)

---

## Testing Checklist (MCP Agent)

After scene configuration, test with:

```gdscript
# 1. Play test scene
play_scene("res://tests/test_story.tscn")

# 2. Check for errors
get_godot_errors()
```

### Manual Testing:
- [ ] Test scene runs without errors
- [ ] Story flags set correctly from choices (watch console output)
- [ ] Choices affect alignment (S21) correctly - check alignment label updates
- [ ] Chapter progression works - advance_chapter button increments chapter
- [ ] Multiple endings reachable:
  - [ ] authentic_good (alignment > 80, relationships > 70)
  - [ ] algorithm_good (alignment < -80, relationships > 70)
  - [ ] neutral_good (alignment -50 to 50, relationships > 60)
  - [ ] bad (relationships < 30)
- [ ] Hidden endings require specific flags (test with help_all_npcs + discover_secret)
- [ ] Story branch changes based on choices (authentic/neutral/algorithm)
- [ ] Ending determination accurate based on alignment + relationships
- [ ] story_config.json loads correctly (no JSON errors in console)
- [ ] Debug info prints correctly
- [ ] Reset button restarts scene properly

### Integration Testing (When S22 Available):
- [ ] NPC relationship tracking affects ending determination
- [ ] Average relationship calculation from NPC system
- [ ] Story choices affect NPC relationships

### Save/Load Testing (with S06):
- [ ] Register StoryManager with SaveManager
- [ ] Save game preserves story state (flags, chapter, branch)
- [ ] Load game restores story state correctly
- [ ] Choice history persists across saves

```gdscript
# 3. Stop scene when done
stop_running_scene()
```

---

## Notes / Gotchas

### Story System Design:
- **10 Endings Total**: 4 standard (authentic_good, algorithm_good, neutral_good, bad), 4 hidden (transcendent endings), 2 secret (true_balance, void)
- **5 Chapters**: Linear progression with branching choices within each chapter
- **3 Story Branches**: Authentic, Neutral, Algorithm - affects narrative tone and available choices
- **17 Choices**: Each with alignment shifts, flags, and branch effects

### Ending Determination Logic:
1. Checks hidden endings first (most restrictive requirements)
2. Then checks good endings based on alignment + relationships
3. Falls back to bad ending if relationships are very low
4. Default to neutral_good if no other conditions met

### Integration Notes:
- **S21 Integration**: Fully implemented - choices shift alignment automatically
- **S22 Integration**: Prepared but optional - uses fallback estimation if S22 not available
- **S06 Integration**: Fully implemented - save_state() and load_state() methods ready

### Configuration:
- All story data in `story_config.json` - no hardcoded story content in GDScript
- Easy to modify chapters, endings, choices, and hidden paths via JSON
- Supports adding new endings/choices without code changes

### GDScript 4.5 Compliance:
- ✓ Uses `.repeat()` for string repetition (not `*`)
- ✓ Includes `class_name StoryManagerImpl` declaration
- ✓ Complete type hints for all functions and parameters
- ✓ No type inference issues - all types explicitly declared
- ✓ Proper autoload access patterns

---

## Next Steps

**MCP Agent Tasks:**
1. ✅ Read this HANDOFF document
2. Configure test scene `res://tests/test_story.tscn` using commands above
3. Create test script `res://tests/test_story_script.gd`
4. Add StoryManager to autoload in project.godot
5. Test in Godot editor using checklist above
6. Update `COORDINATION-DASHBOARD.md` to mark S23 complete
7. Create knowledge base entry if any non-trivial issues solved

**Expected Completion Time:** 30-45 minutes

---

**Status:** Ready for Tier 2 (MCP Agent) ✅

**Job 4 (Progression Systems) Status:** S23 complete when MCP agent finishes Tier 2 testing
