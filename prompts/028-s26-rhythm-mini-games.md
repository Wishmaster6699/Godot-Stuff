<objective>
Implement Rhythm Mini-Games (S26) - story moments requiring rhythm, boss battles with rhythm phases, training/practice modes, combo chains for perfect sequences (+1 multiplier each), difficulty scaling (normal/hard/expert).

DEPENDS ON: S01 (Conductor), S04 (Combat for boss phases)
WAVE 1 - Can run in parallel with S19, S24, S25
</objective>

<context>
Rhythm mini-games are special gameplay moments where rhythm is the primary mechanic. They appear in story events, boss battles, and training.

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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S26")`
- [ ] Quality gates: `check_quality_gates("S26")`
- [ ] Checkpoint validation: `validate_checkpoint("S26")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S26", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

## Implementation

### 1. Rhythm Mini-Game System
Create `res://mini_games/rhythm_game.gd`:
```gdscript
var combo_count = 0
var combo_multiplier = 1.0

func _on_beat_hit(timing_quality: String):
  if timing_quality == "perfect":
    combo_count += 1
    combo_multiplier = 1.0 + (combo_count * 0.1)  # +10% per perfect
  else:
    combo_count = 0
    combo_multiplier = 1.0
```

### 2. Mini-Game Types

**Story Rhythm Moments:**
- Scripted sequences during cutscenes
- Player must hit beats to progress story
- Failure = retry, no penalty

**Boss Rhythm Phases:**
- Boss enters "rhythm phase" mid-battle
- Player must complete rhythm sequence
- Success = boss stunned, extra damage
- Failure = boss enraged, harder attacks

**Training Mode:**
- Practice rhythm patterns
- No stakes, just skill building
- Tracks high scores

### 3. Combo System
- Perfect hit: +1 combo
- Good hit: Maintain combo
- Miss: Reset combo to 0
- Combo multiplier: 1.0 + (combo * 0.1), max 3.0x

### 4. Difficulty Scaling
```json
{
  "difficulty_config": {
    "normal": {
      "timing_window_ms": 100,
      "pattern_complexity": "simple",
      "bpm": 120
    },
    "hard": {
      "timing_window_ms": 70,
      "pattern_complexity": "moderate",
      "bpm": 150
    },
    "expert": {
      "timing_window_ms": 50,
      "pattern_complexity": "complex",
      "bpm": 180
    }
  }
}
```

### 5. Rhythm Patterns
- 4/4 simple: Quarter notes
- 3/4 waltz: Triplets
- Polyrhythm: 4:3, 5:4 (from S18)
- Syncopation: Off-beat patterns

### 6. Visual Feedback
- Note highway (Guitar Hero style)
- Perfect/Good/Miss indicators
- Combo counter
- Multiplier display

### 7. Rewards
- Story moments: Unlock story flags
- Boss phases: Stun boss, bonus damage
- Training: Unlock new patterns, achievements

### 8. Test Scene
- Rhythm game UI
- Multiple difficulty levels
- Combo tracking
- Boss phase integration

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://mini_games/rhythm_game.gd` - Complete rhythm mini-game system with combo tracking, difficulty scaling, pattern validation
   - Story moment integration
   - Boss rhythm phase integration
   - Training mode
   - Type hints, documentation, error handling

2. **Create all JSON data files** using the Write tool
   - `res://data/rhythm_patterns.json` - Rhythm patterns for different difficulty levels
   - `res://data/difficulty_config.json` - Difficulty scaling configuration
   - Valid JSON format with all required fields

3. **Create HANDOFF-S26.md** documenting:
   - Scene structures needed (rhythm game UI test scene)
   - MCP agent tasks (use GDAI tools)
   - Property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- `res://mini_games/rhythm_game.gd` - Complete rhythm mini-game implementation
- `res://data/rhythm_patterns.json` - Rhythm patterns data
- `res://data/difficulty_config.json` - Difficulty configuration
- `HANDOFF-S26.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S26.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create test_rhythm_game.tscn
   - `add_node` - Build node hierarchies for rhythm UI
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set node properties
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S26.md` with this structure:

```markdown
# System S26 Handoff - Rhythm Mini-Games

**Created by:** Claude Code Web
**Date:** [timestamp]
**Status:** Ready for MCP Agent Configuration

---

## Files Created (Tier 1 Complete)

### GDScript Files
- `res://mini_games/rhythm_game.gd` - Rhythm mini-game system with combo tracking, difficulty scaling, pattern validation

### Data Files
- `res://data/rhythm_patterns.json` - Rhythm patterns for different difficulty levels
- `res://data/difficulty_config.json` - Difficulty scaling configuration

---

## Scene Configuration Needed (Tier 2 - MCP Agent Tasks)

### Scene 1: `res://tests/test_rhythm_game.tscn`

**MCP Agent Commands:**
```gdscript
# Create test scene
create_scene("res://tests/test_rhythm_game.tscn", "Node2D", "TestRhythmGame")

# Add UI elements
add_node("TestRhythmGame", "Control", "RhythmUI")
add_node("TestRhythmGame/RhythmUI", "Label", "ComboDisplay")
add_node("TestRhythmGame/RhythmUI", "Label", "MultiplierDisplay")
add_node("TestRhythmGame/RhythmUI", "Label", "TimingFeedback")
add_node("TestRhythmGame/RhythmUI", "ProgressBar", "NoteHighway")
add_node("TestRhythmGame", "VBoxContainer", "DifficultyButtons")
add_node("TestRhythmGame/DifficultyButtons", "Button", "Normal")
add_node("TestRhythmGame/DifficultyButtons", "Button", "Hard")
add_node("TestRhythmGame/DifficultyButtons", "Button", "Expert")

# Configure properties
update_property("TestRhythmGame/RhythmUI", "position", Vector2(100, 100))
update_property("TestRhythmGame/RhythmUI", "size", Vector2(600, 400))
update_property("TestRhythmGame/RhythmUI/ComboDisplay", "position", Vector2(10, 10))
update_property("TestRhythmGame/RhythmUI/MultiplierDisplay", "position", Vector2(10, 40))
update_property("TestRhythmGame/RhythmUI/TimingFeedback", "position", Vector2(250, 150))
update_property("TestRhythmGame/RhythmUI/NoteHighway", "position", Vector2(50, 300))
update_property("TestRhythmGame/RhythmUI/NoteHighway", "size", Vector2(500, 50))
update_property("TestRhythmGame/DifficultyButtons", "position", Vector2(10, 550))
update_property("TestRhythmGame/Normal", "text", "Normal (100ms)")
update_property("TestRhythmGame/Hard", "text", "Hard (70ms)")
update_property("TestRhythmGame/Expert", "text", "Expert (50ms)")
```

**Node Hierarchy:**
```
TestRhythmGame (Node2D)
├── RhythmUI (Control)
│   ├── ComboDisplay (Label)
│   ├── MultiplierDisplay (Label)
│   ├── TimingFeedback (Label)
│   └── NoteHighway (ProgressBar)
└── DifficultyButtons (VBoxContainer)
    ├── Normal (Button)
    ├── Hard (Button)
    └── Expert (Button)
```

---

## Integration Points

### Signals Exposed:
- `beat_hit(timing_quality: String)` - Emitted when player hits a beat
- `combo_changed(new_combo: int)` - Emitted when combo count changes
- `sequence_complete(success: bool)` - Emitted when rhythm sequence completes
- `boss_stunned()` - Emitted when boss rhythm phase succeeds

### Public Methods:
- `start_rhythm_sequence(pattern_id: String, difficulty: String)` - Start a rhythm sequence
- `evaluate_input(input_time: float) -> String` - Evaluate player input timing
- `get_combo_multiplier() -> float` - Get current combo multiplier
- `reset_combo()` - Reset combo to 0

### Dependencies:
- Depends on: S01 (Conductor), S04 (Combat for boss phases)
- Depended on by: None (optional enhancement system)

---

## Testing Checklist (MCP Agent)

After scene configuration, test with:

```gdscript
# Play test scene
play_scene("res://tests/test_rhythm_game.tscn")

# Check for errors
get_godot_errors()

# Verify:
```
- [ ] Rhythm game UI works (note highway)
- [ ] Combo system tracks perfect hits
- [ ] Combo multiplier increases (max 3.0x)
- [ ] Difficulty scaling works (timing windows: 100ms/70ms/50ms)
- [ ] Story moments trigger rhythm sequences
- [ ] Boss rhythm phases integrate with S04 Combat
- [ ] Training mode available
- [ ] Integration with Conductor (S01) works
- [ ] Visual feedback clear (Perfect/Good/Miss)
- [ ] Rewards granted on completion
- [ ] rhythm_patterns.json loads correctly
- [ ] difficulty_config.json loads correctly

```gdscript
# Stop scene when done
stop_running_scene()
```

---

## Notes / Gotchas

- **Combo System**: Perfect hit +1 combo, Good maintains, Miss resets
- **Multiplier**: 1.0 + (combo * 0.1), max 3.0x
- **Difficulty Levels**: Normal (100ms), Hard (70ms), Expert (50ms)
- **Boss Integration**: Rhythm phase can stun boss or enrage on failure
- **Training Mode**: No stakes, just skill building with high score tracking

---

**Next Steps:** MCP agent should execute all commands above, then update COORDINATION-DASHBOARD.md to mark S26 complete (ALL 26 SYSTEMS COMPLETE!).
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S26.md, verify:

### Code Quality
- [ ] rhythm_game.gd created with complete implementation (no TODOs or placeholders)
- [ ] rhythm_patterns.json created with valid JSON (no syntax errors)
- [ ] difficulty_config.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented where needed
- [ ] Combo tracking system implemented
- [ ] Difficulty scaling implemented
- [ ] Pattern validation implemented
- [ ] Integration with S01 and S04 documented

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (mini_games/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S26.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] All rhythm data configurable from JSON files
- [ ] No hardcoded patterns in rhythm_game.gd
- [ ] Signal parameters documented
- [ ] Public methods have return type hints
- [ ] Configuration validation logic included

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] test_rhythm_game.tscn created using `create_scene`
- [ ] All test scene nodes added using `add_node`
- [ ] Properties configured using `update_property`

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S26")`
- [ ] Quality gates passed: `check_quality_gates("S26")`
- [ ] Checkpoint validated: `validate_checkpoint("S26")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Rhythm game UI works (note highway displays)
- [ ] Combo system tracks perfect hits correctly
- [ ] Combo multiplier increases (max 3.0x, formula: 1.0 + combo * 0.1)
- [ ] Difficulty scaling works (timing windows adjust)
- [ ] Story moments can trigger rhythm sequences
- [ ] Boss rhythm phases integrate with S04 Combat
- [ ] Training mode available for practice
- [ ] Integration with Conductor (S01) for beat timing
- [ ] Visual feedback clear (Perfect/Good/Miss indicators)
- [ ] Rewards granted on completion
- [ ] rhythm_patterns.json loads correctly
- [ ] difficulty_config.json loads correctly

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ rhythm_game.gd complete with combo tracking, difficulty scaling, pattern validation
- ✅ rhythm_patterns.json complete with rhythm patterns for all difficulty levels
- ✅ difficulty_config.json complete with timing windows and BPM settings
- ✅ Combo multiplier logic (1.0 + combo * 0.1, max 3.0x)
- ✅ All code documented with type hints and comments
- ✅ HANDOFF-S26.md provides clear MCP agent instructions
- ✅ All rhythm data configurable from JSON (no hardcoding)

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Test scene configured correctly in Godot editor
- ✅ Rhythm game UI functional with note highway
- ✅ Combo system tracks perfect sequences
- ✅ Multiplier scales correctly up to 3.0x
- ✅ Difficulty levels adjust timing windows (Normal/Hard/Expert)
- ✅ Story moments can trigger rhythm sequences
- ✅ Boss rhythm phases stun on success, enrage on failure
- ✅ Training mode available for skill building
- ✅ Integrates with S01 Conductor for precise beat timing
- ✅ Integrates with S04 Combat for boss phases
- ✅ Visual feedback clear and responsive
- ✅ ALL 26 SYSTEMS COMPLETE - Rhythm RPG fully specified!

Rhythm mini-games add engaging skill-based challenges to key story and combat moments.

</success_criteria>

### Framework Quality Gates (REQUIRED)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Quality gates passed: `check_quality_gates("S26")`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S26")`
- [ ] Checkpoint validated: `validate_checkpoint("S26")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created: Document solutions in `knowledge-base/` if non-trivial

### System-Specific Verification

- [ ] Rhythm game UI works (note highway)
- [ ] Combo system tracks perfect hits
- [ ] Combo multiplier increases (max 3.0x)
- [ ] Difficulty scaling works (timing windows)
- [ ] Story moments trigger rhythm sequences
- [ ] Boss rhythm phases integrate with S04 Combat
- [ ] Training mode available
- [ ] Integration with Conductor (S01)
- [ ] Visual feedback clear (Perfect/Good/Miss)
- [ ] Rewards granted on completion
</verification>

<memory_checkpoint_format>
```
System S26 (Rhythm Mini-Games) Complete

FILES:
- res://mini_games/rhythm_game.gd
- res://mini_games/ui/rhythm_ui.tscn
- res://data/rhythm_patterns.json

MINI-GAME TYPES:
- Story rhythm moments
- Boss rhythm phases
- Training mode

COMBO SYSTEM:
- Perfect: +1 combo
- Multiplier: 1.0 + (combo * 0.1), max 3.0x

DIFFICULTY LEVELS:
- Normal: 100ms window, 120 BPM
- Hard: 70ms window, 150 BPM
- Expert: 50ms window, 180 BPM

ALL 26 SYSTEMS COMPLETE!
STATUS: Rhythm RPG fully specified, ready for implementation
```
</memory_checkpoint_format>
