<objective>
Implement Player Progression with Branching Story (S23) - main storyline with 3+ branching paths, choices affecting quests/relationships/alignment, multiple endings (good/neutral/bad minimum), hidden paths, character backstory reveals, story flags in save system.

DEPENDS ON: S22 (NPCs for story), S21 (Alignment for endings), S04 (Combat story events)
WAVE 4 - Sequential (needs S22 complete)
</objective>

<context>
The story system tracks player choices, manages branching paths, and determines ending based on alignment and relationship totals.

Reference:
@rhythm-rpg-implementation-guide.md
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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S23")`
- [ ] Quality gates: `check_quality_gates("S23")`
- [ ] Checkpoint validation: `validate_checkpoint("S23")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S23", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

## Implementation

### 1. Story Manager
Create `res://story/story_manager.gd`:
```gdscript
var story_flags = []  # ["met_elder", "saved_village", etc.]
var current_chapter = 1
var story_branch = "neutral"  # authentic, neutral, algorithm

signal story_flag_set(flag)
signal chapter_complete(chapter)
signal ending_reached(ending_type)
```

### 2. Story Configuration
```json
{
  "story_config": {
    "chapters": [
      {
        "id": 1,
        "name": "The Awakening",
        "main_quest": "discover_rhythm",
        "branching_points": ["choice_help_village", "choice_confront_elder"]
      }
    ],
    "endings": {
      "authentic_good": {
        "requirements": { "alignment": ">80", "relationships_avg": ">70" }
      },
      "algorithm_good": {
        "requirements": { "alignment": "<-80", "relationships_avg": ">70" }
      },
      "neutral": {
        "requirements": { "alignment": "-50 to 50" }
      },
      "bad": {
        "requirements": { "relationships_avg": "<30" }
      }
    }
  }
}
```

### 3. Choice System
```gdscript
func make_story_choice(choice_id: String):
  match choice_id:
    "help_village":
      set_story_flag("helped_village")
      ResonanceAlignment.shift_alignment(10, "Helped village")
      story_branch = "authentic"
    "confront_elder":
      set_story_flag("confronted_elder")
      ResonanceAlignment.shift_alignment(-10, "Confronted elder")
      story_branch = "algorithm"
```

### 4. Quest Integration
- Main quests advance story chapters
- Side quests reveal character backstory
- Hidden quests unlock secret endings

### 5. Ending Determination
```gdscript
func determine_ending():
  var alignment = ResonanceAlignment.alignment
  var avg_relationship = calculate_avg_npc_relationship()
  
  if alignment > 80 and avg_relationship > 70:
    return "authentic_good"
  elif alignment < -80 and avg_relationship > 70:
    return "algorithm_good"
  # ...etc
```

### 6. Save Integration (S06)
Story flags saved in save file

### 7. Test Scene
- Story choices affect flags
- Alignment shifts from choices
- Ending calculation preview

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://story/story_manager.gd` - Complete story manager with flag tracking, chapter progression, branching paths, ending determination
   - Choice system integration
   - Ending calculation logic based on alignment and relationships
   - Type hints, documentation, error handling

2. **Create all JSON data files** using the Write tool
   - `res://data/story_config.json` - Complete story configuration with chapters, branching points, ending requirements
   - Valid JSON format with all required fields

3. **Create HANDOFF-S23.md** documenting:
   - Scene structures needed (test scene for story progression)
   - MCP agent tasks (use GDAI tools)
   - Property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- `res://story/story_manager.gd` - Complete story system implementation
- `res://data/story_config.json` - Story configuration data
- `HANDOFF-S23.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S23.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create test_story.tscn
   - `add_node` - Build node hierarchies for test scenes
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set node properties
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S23.md` with this structure:

```markdown
# System S23 Handoff - Player Progression/Story System

**Created by:** Claude Code Web
**Date:** [timestamp]
**Status:** Ready for MCP Agent Configuration

---

## Files Created (Tier 1 Complete)

### GDScript Files
- `res://story/story_manager.gd` - Story manager with flag tracking, chapter progression, branching paths, ending determination

### Data Files
- `res://data/story_config.json` - Story configuration with chapters, branching points, ending requirements

---

## Scene Configuration Needed (Tier 2 - MCP Agent Tasks)

### Scene 1: `res://tests/test_story.tscn`

**MCP Agent Commands:**
```gdscript
# Create test scene
create_scene("res://tests/test_story.tscn", "Node2D", "TestStory")

# Add UI elements for testing
add_node("TestStory", "Label", "CurrentChapter")
add_node("TestStory", "Label", "StoryBranch")
add_node("TestStory", "Label", "StoryFlags")
add_node("TestStory", "Label", "EndingPreview")
add_node("TestStory", "VBoxContainer", "StoryChoices")
add_node("TestStory/StoryChoices", "Button", "HelpVillageChoice")
add_node("TestStory/StoryChoices", "Button", "ConfrontElderChoice")
add_node("TestStory/StoryChoices", "Button", "CalculateEnding")

# Configure properties
update_property("TestStory/CurrentChapter", "position", Vector2(10, 10))
update_property("TestStory/StoryBranch", "position", Vector2(10, 40))
update_property("TestStory/StoryFlags", "position", Vector2(10, 70))
update_property("TestStory/EndingPreview", "position", Vector2(10, 100))
update_property("TestStory/StoryChoices", "position", Vector2(10, 150))
update_property("TestStory/HelpVillageChoice", "text", "Help Village (Authentic +10)")
update_property("TestStory/ConfrontElderChoice", "text", "Confront Elder (Algorithm -10)")
update_property("TestStory/CalculateEnding", "text", "Calculate Ending")
```

**Node Hierarchy:**
```
TestStory (Node2D)
├── CurrentChapter (Label)
├── StoryBranch (Label)
├── StoryFlags (Label)
├── EndingPreview (Label)
└── StoryChoices (VBoxContainer)
    ├── HelpVillageChoice (Button)
    ├── ConfrontElderChoice (Button)
    └── CalculateEnding (Button)
```

---

## Integration Points

### Signals Exposed:
- `story_flag_set(flag: String)` - Emitted when story flag is set
- `chapter_complete(chapter_id: int)` - Emitted when chapter completes
- `ending_reached(ending_type: String)` - Emitted when ending is reached
- `branch_changed(new_branch: String)` - Emitted when story branch changes

### Public Methods:
- `set_story_flag(flag: String)` - Set a story flag
- `has_story_flag(flag: String) -> bool` - Check if flag is set
- `make_story_choice(choice_id: String)` - Make a story choice
- `determine_ending() -> String` - Calculate ending based on alignment and relationships
- `advance_chapter()` - Move to next chapter

### Dependencies:
- Depends on: S22 (NPCs for story), S21 (Alignment for endings), S04 (Combat story events)
- Depended on by: None (final story system)

---

## Testing Checklist (MCP Agent)

After scene configuration, test with:

```gdscript
# Play test scene
play_scene("res://tests/test_story.tscn")

# Check for errors
get_godot_errors()

# Verify:
```
- [ ] Story flags set correctly from choices
- [ ] Choices affect alignment (S21) correctly
- [ ] Choices affect NPC relationships (S22)
- [ ] Multiple endings reachable (authentic_good, algorithm_good, neutral, bad)
- [ ] Hidden story paths discoverable
- [ ] Chapter progression works
- [ ] Save/Load (S06) persists story state
- [ ] Ending determination accurate (based on alignment + relationships)
- [ ] Integration with S22 NPCs works
- [ ] Integration with S21 Alignment works
- [ ] story_config.json loads correctly

```gdscript
# Stop scene when done
stop_running_scene()
```

---

## Notes / Gotchas

- **Ending Determination**: Based on alignment (-100 to +100) AND average NPC relationships
- **Story Branches**: Authentic, Neutral, Algorithm (3 main paths)
- **Hidden Paths**: Require specific flag combinations
- **Save Integration**: All story flags saved with S06 Save/Load system
- **Multiple Endings**: Minimum 4 (authentic_good, algorithm_good, neutral, bad)

---

**Next Steps:** MCP agent should execute all commands above, then update COORDINATION-DASHBOARD.md to mark S23 complete (Job 4 complete).
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S23.md, verify:

### Code Quality
- [ ] story_manager.gd created with complete implementation (no TODOs or placeholders)
- [ ] story_config.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented where needed
- [ ] Story flag tracking implemented
- [ ] Chapter progression system implemented
- [ ] Branching path logic implemented
- [ ] Ending determination logic implemented
- [ ] Integration with S21 and S22 documented

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (story/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S23.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] All story data configurable from story_config.json
- [ ] No hardcoded story data in story_manager.gd
- [ ] Signal parameters documented
- [ ] Public methods have return type hints
- [ ] Configuration validation logic included

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] test_story.tscn created using `create_scene`
- [ ] All test scene nodes added using `add_node`
- [ ] Properties configured using `update_property`

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S23")`
- [ ] Quality gates passed: `check_quality_gates("S23")`
- [ ] Checkpoint validated: `validate_checkpoint("S23")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Story flags set correctly from choices
- [ ] Choices affect alignment (S21) correctly
- [ ] Choices affect NPC relationships (S22)
- [ ] Multiple endings reachable (authentic_good, algorithm_good, neutral, bad)
- [ ] Hidden story paths discoverable
- [ ] Chapter progression works
- [ ] Save/Load (S06) persists story state
- [ ] Ending determination accurate (based on alignment + relationships)
- [ ] Integration with S22 NPCs works
- [ ] Integration with S21 Alignment works
- [ ] story_config.json loads correctly

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ story_manager.gd complete with flag tracking, chapter progression, branching paths
- ✅ story_config.json complete with all story configuration data
- ✅ Ending determination logic based on alignment and relationships
- ✅ All code documented with type hints and comments
- ✅ HANDOFF-S23.md provides clear MCP agent instructions
- ✅ All story data configurable from JSON (no hardcoding)

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Test scene configured correctly in Godot editor
- ✅ Story flag system tracks player choices
- ✅ Chapter progression system works
- ✅ Branching paths based on choices (Authentic, Neutral, Algorithm)
- ✅ Multiple endings reachable (minimum 4: authentic_good, algorithm_good, neutral, bad)
- ✅ Hidden story paths can be discovered
- ✅ Ending calculation accurate based on alignment + average NPC relationships
- ✅ Integrates with S22 NPCs for story delivery
- ✅ Integrates with S21 Alignment for ending determination
- ✅ Integrates with S06 Save/Load for story persistence
- ✅ JOB 4 COMPLETE - All progression systems functional

This completes the story and progression systems - the narrative heart of the game.

</success_criteria>

<memory_checkpoint_format>
```
System S23 (Player Progression/Story) Complete

FILES:
- res://story/story_manager.gd
- res://data/story_config.json
- res://story/chapters/[chapter_id].gd

STORY STRUCTURE:
- 5+ chapters
- 3 main branches (Authentic, Neutral, Algorithm)
- 4+ endings

ENDINGS:
- Authentic Good
- Algorithm Good
- Neutral
- Bad
- (Hidden endings possible)

INTEGRATION:
- NPCs (S22) for dialogue/quests
- Alignment (S21) for ending determination
- Save/Load (S06) for story persistence

JOB 4 PROGRESSION SYSTEMS COMPLETE
STATUS: Story complete, ready for content systems (S24, S25, S26)
```
</memory_checkpoint_format>
