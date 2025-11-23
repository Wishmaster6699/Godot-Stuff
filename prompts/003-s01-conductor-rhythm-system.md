<objective>
Implement the Conductor/Rhythm System (S01) - the master beat synchronization system that powers ALL rhythm-dependent mechanics in the game. This system emits signals on downbeat, upbeat, and custom beat intervals with audio latency compensation.

This is a FOUNDATION system with no dependencies. It can run in parallel with S02 and S03 implementations.
</objective>

<context>
The Conductor is the heartbeat of the entire game. Every rhythm-based mechanic (combat, traversal, puzzles, environment) listens to this system's signals. It must be rock-solid, precise, and handle audio latency gracefully.

Systems that will depend on this:
- **S04**: Combat Prototype (rhythm attacks)
- **S09**: Dodge/Block Mechanics (rhythm timing)
- **S10**: Special Moves (upbeat triggers)
- **S16**: Grind Rail Traversal (balance on beat)
- **S17**: Puzzle System (rhythm puzzles)
- **S18**: Polyrhythmic Environment (animated elements)
- **S26**: Rhythm Mini-Games (story moments)

Reference:
@rhythm-rpg-implementation-guide.md (lines 150-244 for S01 specification)
@vibe-code-philosophy.md (for workflow principles)
@godot-mcp-command-reference.md (for MCP commands)
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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S01")`
- [ ] Quality gates: `check_quality_gates("S01")`
- [ ] Checkpoint validation: `validate_checkpoint("S01")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S01", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

## Implementation Tasks

### 1. Web Research First
Search for and study:
- "Godot 4.5 rhythm game synchronization 2025"
- "RhythmNotifier plugin Godot 4.5"
- "Godot AudioServer latency compensation"
- "Godot 4.5 autoload singletons best practices"

Visit: https://github.com/voidshine/godot_rhythm_notifier
- Understand plugin API
- Note installation requirements
- Find signal emission patterns
- Understand BPM configuration

### 2. Plugin Integration
- Install RhythmNotifier plugin via AssetLib or GitHub clone
- Enable in Project Settings → Plugins
- Verify plugin loads correctly

### 3. Conductor Autoload Creation

Create `res://autoloads/conductor.gd` as singleton autoload.

The Conductor must:
- Manage RhythmNotifier node instance
- Load rhythm configuration from `res://data/rhythm_config.json`
- Emit standardized signals: `downbeat`, `upbeat`, `beat(beat_number)`, `measure_complete`
- Implement latency compensation using `AudioServer.get_output_latency()`
- Provide timing quality evaluation: `get_timing_quality(input_timestamp)` returns "perfect"/"good"/"miss"
- Support runtime BPM changes
- Prevent audio drift over extended playback

### 4. Data-Driven Configuration

Create `res://data/rhythm_config.json` with structure:
```json
{
  "rhythm_config": {
    "default_bpm": 120,
    "timing_windows": {
      "perfect": { "offset_ms": 50, "score_multiplier": 2.0 },
      "good": { "offset_ms": 100, "score_multiplier": 1.5 },
      "miss": { "offset_ms": 150, "score_multiplier": 0.0 }
    },
    "latency_compensation_ms": 0,
    "visual_feedback": {
      "beat_flash_duration": 0.1,
      "downbeat_color": "#00FF00",
      "upbeat_color": "#FFFF00"
    }
  }
}
```

All values should be configurable from this JSON (no hardcoding in script).

### 5. Core Signal Emissions

Implement signals:
- **downbeat**: Emitted every 4 beats (measure start)
- **upbeat**: Emitted on beats 2 and 4
- **beat(beat_number)**: Emitted on every beat with index
- **measure_complete**: Emitted at end of measure

Signals must be frame-accurate and account for audio latency.

### 6. Timing Quality Evaluation

Implement `get_timing_quality(input_timestamp: float) -> String` method:
- Compare input_timestamp against nearest beat time
- Account for latency compensation
- Return "perfect" if within ±50ms (configurable)
- Return "good" if within ±100ms (configurable)
- Return "miss" if >100ms (configurable)

This method will be called by all rhythm-dependent systems.

### 7. Debug Visualization (Optional but Recommended)

Create `res://debug/rhythm_debug_overlay.tscn`:
- Visual beat indicator (flashing on downbeat/upbeat)
- BPM display
- Latency compensation value
- Current beat number
- Timing window visualization (perfect/good/miss zones)

Toggle with debug key (F3 or similar).

### 8. Test Scene Creation

Create `res://tests/test_conductor.tscn`:
- Conductor autoload reference
- Test audio track (120 BPM, 180 BPM, 60 BPM)
- Visual feedback for beat emissions
- Input detection to test timing quality
- Display timing quality results (perfect/good/miss)

Test with:
- 3 different BPM values (60, 120, 180)
- Runtime BPM changes mid-song
- Extended playback (2+ minutes) to verify no drift
- Various input timings to verify quality evaluation

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://autoloads/conductor.gd` - Complete Conductor singleton implementation
   - Full logic with signal emissions, latency compensation, timing quality evaluation
   - Type hints, documentation, error handling
   - Integration with RhythmNotifier plugin

2. **Create all JSON data files** using the Write tool
   - `res://data/rhythm_config.json` - Complete timing windows and BPM configuration
   - Valid JSON format with all required fields

3. **Create HANDOFF-S01.md** documenting:
   - Scene structures needed (test scene, debug overlay)
   - MCP agent tasks (use GDAI tools)
   - Property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- `res://autoloads/conductor.gd` - Complete Conductor implementation
- `res://data/rhythm_config.json` - Rhythm configuration data
- `HANDOFF-S01.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)
- Register autoload in project settings (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S01.md
2. Use GDAI tools to configure scenes:
   - Register Conductor as autoload in project settings
   - `create_scene` - Create test_conductor.tscn and rhythm_debug_overlay.tscn
   - `add_node` - Build node hierarchies for test scenes
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set node properties
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S01.md` with this structure:

```markdown
# System S01 Handoff - Conductor/Rhythm System

**Created by:** Claude Code Web
**Date:** [timestamp]
**Status:** Ready for MCP Agent Configuration

---

## Files Created (Tier 1 Complete)

### GDScript Files
- `res://autoloads/conductor.gd` - Conductor singleton with signal emissions, latency compensation, timing quality evaluation

### Data Files
- `res://data/rhythm_config.json` - Timing windows, BPM config, visual feedback settings

---

## Scene Configuration Needed (Tier 2 - MCP Agent Tasks)

### Autoload Registration

**MCP Agent Task:**
Register Conductor as autoload singleton in Project Settings:
```gdscript
# Add to Project Settings → Autoload
# Autoload Name: Conductor
# Script Path: res://autoloads/conductor.gd
# Order: 1 (should be first - other systems depend on it)
```

### Scene 1: `res://tests/test_conductor.tscn`

**MCP Agent Commands:**
```bash
# Create test scene
create_scene res://tests/test_conductor.tscn

# Add UI elements for testing
add_node res://tests/test_conductor.tscn Label BPMDisplay root
add_node res://tests/test_conductor.tscn Label BeatDisplay root
add_node res://tests/test_conductor.tscn Label TimingQualityDisplay root
add_node res://tests/test_conductor.tscn ColorRect BeatFlash root

# Add audio player for test track
add_node res://tests/test_conductor.tscn AudioStreamPlayer TestAudio root

# Configure properties
update_property res://tests/test_conductor.tscn BPMDisplay position "Vector2(10, 10)"
update_property res://tests/test_conductor.tscn BeatDisplay position "Vector2(10, 40)"
update_property res://tests/test_conductor.tscn TimingQualityDisplay position "Vector2(10, 70)"
update_property res://tests/test_conductor.tscn BeatFlash position "Vector2(400, 300)"
update_property res://tests/test_conductor.tscn BeatFlash size "Vector2(100, 100)"
update_property res://tests/test_conductor.tscn BeatFlash color "Color(0, 1, 0, 0.5)"
```

**Node Hierarchy:**
```
TestConductor (Node2D)
├── BPMDisplay (Label)
├── BeatDisplay (Label)
├── TimingQualityDisplay (Label)
├── BeatFlash (ColorRect)
└── TestAudio (AudioStreamPlayer)
```

**Property Configurations:**
- BPMDisplay: Display current BPM
- BeatDisplay: Display current beat number
- TimingQualityDisplay: Display input timing quality (perfect/good/miss)
- BeatFlash: Visual feedback on beat (flash green on downbeat, yellow on upbeat)
- TestAudio: Load test track (120 BPM audio file)

### Scene 2: `res://debug/rhythm_debug_overlay.tscn`

**MCP Agent Commands:**
```bash
# Create debug overlay scene
create_scene res://debug/rhythm_debug_overlay.tscn

# Add debug UI elements
add_node res://debug/rhythm_debug_overlay.tscn Panel DebugPanel root
add_node res://debug/rhythm_debug_overlay.tscn VBoxContainer DebugInfo DebugPanel
add_node res://debug/rhythm_debug_overlay.tscn Label BPMLabel DebugInfo
add_node res://debug/rhythm_debug_overlay.tscn Label BeatLabel DebugInfo
add_node res://debug/rhythm_debug_overlay.tscn Label LatencyLabel DebugInfo
add_node res://debug/rhythm_debug_overlay.tscn Label TimingWindowsLabel DebugInfo

# Configure properties
update_property res://debug/rhythm_debug_overlay.tscn DebugPanel position "Vector2(10, 10)"
update_property res://debug/rhythm_debug_overlay.tscn DebugPanel size "Vector2(250, 150)"
update_property res://debug/rhythm_debug_overlay.tscn root layer 100
```

**Node Hierarchy:**
```
RhythmDebugOverlay (CanvasLayer)
└── DebugPanel (Panel)
    └── DebugInfo (VBoxContainer)
        ├── BPMLabel (Label)
        ├── BeatLabel (Label)
        ├── LatencyLabel (Label)
        └── TimingWindowsLabel (Label)
```

---

## Integration Points

### Signals Exposed:
- `downbeat()` - Emitted every 4 beats (measure start)
- `upbeat()` - Emitted on beats 2 and 4
- `beat(beat_number: int)` - Emitted on every beat
- `measure_complete()` - Emitted at end of measure

### Public Methods:
- `get_timing_quality(input_timestamp: float) -> String` - Returns "perfect"/"good"/"miss"
- `set_bpm(new_bpm: float)` - Change BPM at runtime
- `get_current_beat() -> int` - Get current beat number

### Dependencies:
- Depends on: RhythmNotifier plugin (must be installed and enabled)
- Depended on by: S04, S09, S10, S16, S17, S18, S26

---

## Testing Checklist (MCP Agent)

After scene configuration, test with:

```bash
# Play test scene
play_scene res://tests/test_conductor.tscn

# Check for errors
get_godot_errors
```

### Verify:
- [ ] Conductor autoload is accessible globally
- [ ] rhythm_config.json loads correctly
- [ ] Downbeat signal emits precisely every 4 beats
- [ ] Upbeat signal emits on beats 2 and 4
- [ ] beat(n) signal emits on every beat with correct index
- [ ] measure_complete signal emits at end of measure
- [ ] Timing quality evaluation works (test with various input timings)
- [ ] Latency compensation applied
- [ ] No audio drift after 2+ minutes of playback (test with extended song)
- [ ] BPM changes mid-song work correctly
- [ ] Test scene displays beat feedback correctly
- [ ] Debug overlay shows correct information (if implemented)

---

## Notes / Gotchas

- **Plugin Dependency**: Ensure RhythmNotifier plugin is installed from AssetLib or GitHub before testing
- **Autoload Order**: Conductor should be first in autoload list (other systems depend on it)
- **Latency Compensation**: AudioServer.get_output_latency() is automatically applied
- **Timing Windows**: All values configurable from rhythm_config.json (no hardcoding)
- **Extended Testing**: Test with 2+ minutes of playback to verify no drift

---

**Next Steps:** MCP agent should execute all commands above, then update COORDINATION-DASHBOARD.md to mark S01 complete and unblock S04, S09, S10, S16, S17, S18, S26.
```

</handoff_requirements>

<implementation_steps>

Follow this workflow:

1. **Research** (allocate 20% of time)
   - Web search for Godot rhythm patterns
   - Study RhythmNotifier plugin docs
   - Understand AudioServer latency API
   - Take notes on best practices

2. **Plugin Setup** (allocate 10% of time)
   - Install RhythmNotifier via AssetLib or clone from GitHub
   - Enable plugin in project settings
   - Test plugin loads without errors

3. **Conductor Script** (allocate 30% of time)
   - Create conductor.gd using Godot MCP
   - Implement signal emissions (downbeat, upbeat, beat, measure_complete)
   - Implement latency compensation
   - Implement timing quality evaluation
   - Load configuration from JSON

4. **Configuration** (allocate 10% of time)
   - Create rhythm_config.json with all timing windows
   - Verify JSON loads correctly
   - Test changing values updates behavior

5. **Debug Tools** (allocate 15% of time)
   - Create rhythm debug overlay scene
   - Visual beat indicator
   - Timing window visualization
   - Toggle mechanism

6. **Test Scene** (allocate 10% of time)
   - Create test_conductor.tscn
   - Add test audio tracks
   - Input detection and timing display
   - Run tests with various BPMs

7. **Verification** (allocate 5% of time)
   - Run all verification criteria (see below)
   - Document any issues
   - Ensure signals emit precisely

8. **Memory Checkpoint** (allocate 0% of time - quick save)
   - Save progress to Basic Memory MCP
   - Document files created and key decisions

</implementation_steps>

<data_driven_architecture>

The rhythm system is entirely data-driven. To customize:

**Add new timing windows:**
```json
"timing_windows": {
  "perfect": { "offset_ms": 50, "score_multiplier": 2.0 },
  "good": { "offset_ms": 100, "score_multiplier": 1.5 },
  "ok": { "offset_ms": 150, "score_multiplier": 1.0 },
  "miss": { "offset_ms": 200, "score_multiplier": 0.0 }
}
```

**Add BPM presets:**
```json
"bpm_presets": {
  "slow": 60,
  "normal": 120,
  "fast": 180,
  "boss_battle": 140
}
```

**Adjust latency compensation:**
```json
"latency_compensation_ms": 50  // Add 50ms offset for high-latency audio
```

All future systems will reference this config, not hardcoded values.

</data_driven_architecture>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S01.md, verify:

### Code Quality
- [ ] conductor.gd created with complete implementation (no TODOs or placeholders)
- [ ] rhythm_config.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented where needed
- [ ] Signal emissions implemented (downbeat, upbeat, beat, measure_complete)
- [ ] Latency compensation logic implemented
- [ ] Timing quality evaluation method implemented
- [ ] BPM change support implemented
- [ ] Integration with RhythmNotifier plugin documented

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (autoloads/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S01.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] All timing windows configurable from rhythm_config.json
- [ ] No hardcoded values in conductor.gd
- [ ] Signal parameters documented
- [ ] Public methods have return type hints
- [ ] Configuration validation logic included

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] RhythmNotifier plugin installed and enabled
- [ ] Conductor registered as autoload in project settings
- [ ] test_conductor.tscn created using `create_scene`
- [ ] All test scene nodes added using `add_node`
- [ ] Properties configured using `update_property`
- [ ] rhythm_debug_overlay.tscn created (if applicable)

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S01")`
- [ ] Quality gates passed: `check_quality_gates("S01")`
- [ ] Checkpoint validated: `validate_checkpoint("S01")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Conductor autoload accessible globally
- [ ] rhythm_config.json loads correctly
- [ ] Downbeat signal emits precisely every 4 beats
- [ ] Upbeat signal emits on beats 2 and 4
- [ ] beat(n) signal emits on every beat with correct index
- [ ] measure_complete signal emits at end of measure
- [ ] Timing quality evaluation works (test with various input timings)
- [ ] Latency compensation applied (verify with AudioServer.get_output_latency())
- [ ] No audio drift after 2+ minutes of playback (test with extended song)
- [ ] BPM changes mid-song work correctly
- [ ] Debug overlay displays beats accurately (if implemented)
- [ ] System handles edge cases (song ends, loop points, silence)

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ conductor.gd complete with all signal emissions and timing logic
- ✅ rhythm_config.json complete with all timing windows and BPM config
- ✅ All code documented with type hints and comments
- ✅ Integration with RhythmNotifier plugin implemented
- ✅ HANDOFF-S01.md provides clear MCP agent instructions
- ✅ All timing values configurable from JSON (no hardcoding)

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Conductor registered as autoload and accessible globally
- ✅ Test scenes configured correctly in Godot editor
- ✅ Any system can connect to Conductor signals and receive precise beat events
- ✅ Timing quality is accurate - perfect/good/miss evaluation is consistent
- ✅ No audio drift - beat alignment stays accurate over extended playback
- ✅ Latency is compensated - input feels responsive despite audio latency
- ✅ Debuggable - developers can see beat timing visually (debug overlay)
- ✅ System ready for dependent systems (S04, S09, S10, S16, S17, S18, S26)

This system is the foundation. It must be rock-solid.

</success_criteria>


<memory_checkpoint_format>

When complete, save to Basic Memory MCP:

```
System S01 (Conductor/Rhythm) Complete

FILES CREATED:
- res://autoloads/conductor.gd (Conductor singleton)
- res://data/rhythm_config.json (Timing windows and BPM config)
- res://tests/test_conductor.tscn (Test scene with 3 BPM variations)
- res://debug/rhythm_debug_overlay.tscn (Optional debug visualization)

SIGNALS EXPOSED:
- downbeat (every 4 beats)
- upbeat (beats 2 and 4)
- beat(beat_number) (every beat)
- measure_complete (end of measure)

KEY METHODS:
- get_timing_quality(input_timestamp) -> "perfect"/"good"/"miss"
- set_bpm(new_bpm)
- get_current_beat()

TIMING WINDOWS:
- Perfect: ±50ms (2.0x multiplier)
- Good: ±100ms (1.5x multiplier)
- Miss: >100ms (0.0x multiplier)

INTEGRATION NOTES:
- All rhythm systems should connect to Conductor signals
- Use get_timing_quality() for input evaluation
- Latency compensation: Auto-applied via AudioServer.get_output_latency()
- No drift observed over 5 minutes of testing

NEXT DEPENDENCIES:
- S04 (Combat Prototype) can now implement rhythm attacks
- S09 (Dodge/Block) can now implement rhythm timing
- S10 (Special Moves) can now trigger on upbeat
- S16, S17, S18, S26 can integrate when ready

STATUS: Ready for dependent systems
```

</memory_checkpoint_format>

<important_notes>

## Token Budget: ~8,000 tokens

Optimize by:
- Referencing RhythmNotifier docs (don't copy entire API)
- Using JSON templates (don't describe every field)
- Concise implementation steps (no verbose explanations)
- MCP commands over manual file operations

## Parallelization

This system is **INDEPENDENT** and can run in parallel with:
- **S02**: Controller Input System
- **S03**: Player Controller (until it needs S02)
- **002**: Combat Specification (pure design work)

It **BLOCKS** these systems (they need S01 complete):
- S04, S09, S10, S16, S17, S18, S26

## Critical Success Factors

1. **Precision**: Beat events must be frame-accurate
2. **Stability**: No drift over extended playback
3. **Latency**: Compensation must feel responsive
4. **Extensibility**: Easy to add new timing windows or BPM presets

</important_notes>
