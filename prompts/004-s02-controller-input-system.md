<objective>
Implement the Controller Input System (S02) - a comprehensive gamepad input manager with 4-lane rhythm input support, input buffering, deadzone configuration, and cross-platform controller compatibility. This system handles all player input for movement, combat, and rhythm interactions.

This is a FOUNDATION system with no dependencies. It can run in parallel with S01 and S03 implementations.
</objective>

<context>
This system translates raw controller input into game actions. It must support:
- **4-lane rhythm input** (Guitar Hero style, A/B/X/Y or equivalent)
- **Analog stick input** (movement, camera)
- **Button presses, holds, and releases**
- **Input buffering** (store last 10 inputs for combo detection)
- **Deadzone configuration** (prevent stick drift)
- **Cross-platform support** (Xbox, PlayStation, Nintendo Switch Pro controllers)

Godot 4.5 uses SDL3 for gamepad support natively - no external plugins needed.

Systems that will depend on this:
- **S03**: Player Controller (movement input)
- **S04**: Combat Prototype (combat input)
- **S09**: Dodge/Block (dodge/block buttons)
- **S10**: Special Moves (button combos)
- **S14**: Tool System (tool switching)
- **S16**: Grind Rail (balance input)

When integrated with S01 (Conductor), this system will timestamp inputs relative to beats for rhythm evaluation.

Reference:
@rhythm-rpg-implementation-guide.md (lines 245-353 for S02 specification)
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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S02")`
- [ ] Quality gates: `check_quality_gates("S02")`
- [ ] Checkpoint validation: `validate_checkpoint("S02")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S02", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

## Implementation Tasks

### 1. Web Research First
Search for and study:
- "Godot 4.5 gamepad input handling 2025"
- "Godot 4.5 SDL3 controller support"
- "Godot Input class best practices"
- "Godot input buffering system"
- "Godot deadzone configuration"

Study Godot docs:
- InputEventJoypadButton: https://docs.godotengine.org/en/4.5/classes/class_inputeventjoypadbutton.html
- InputEventJoypadMotion: https://docs.godotengine.org/en/4.5/classes/class_inputeventjoypadmotion.html
- Input singleton: https://docs.godotengine.org/en/4.5/classes/class_input.html

### 2. InputManager Autoload Creation

Create `res://autoloads/input_manager.gd` as singleton autoload.

The InputManager must:
- Map controller buttons to 4 rhythm lanes (lane 0-3)
- Detect button presses, holds (>0.3s), and releases
- Track analog stick input with deadzone filtering
- Maintain input buffer (last 10 inputs with timestamps)
- Emit signals for all input events
- Support input remapping at runtime
- Handle controller connect/disconnect gracefully
- Support multiple controller layouts (Xbox, PlayStation, Nintendo)

### 3. Data-Driven Configuration

Create `res://data/input_config.json` with structure:
```json
{
  "input_config": {
    "rhythm_lanes": [
      { "lane_id": 0, "button": "joy_button_0", "label": "A", "color": "#00FF00" },
      { "lane_id": 1, "button": "joy_button_1", "label": "B", "color": "#FF0000" },
      { "lane_id": 2, "button": "joy_button_2", "label": "X", "color": "#0000FF" },
      { "lane_id": 3, "button": "joy_button_3", "label": "Y", "color": "#FFFF00" }
    ],
    "deadzones": {
      "left_stick": 0.2,
      "right_stick": 0.2,
      "triggers": 0.1
    },
    "input_buffer": {
      "max_size": 10,
      "retention_time_ms": 200
    },
    "action_mappings": {
      "move": { "type": "analog", "stick": "left" },
      "camera": { "type": "analog", "stick": "right" },
      "interact": { "type": "button", "button": "joy_button_0" },
      "dodge": { "type": "button", "button": "joy_button_1" },
      "block": { "type": "button", "button": "joy_button_2" },
      "special": { "type": "button", "button": "joy_button_4" },
      "pause": { "type": "button", "button": "joy_button_6" }
    }
  }
}
```

All button mappings configurable from JSON (no hardcoding).

### 4. Core Signal Emissions

Implement signals:
- **lane_pressed(lane_id: int, timestamp: float)**: Rhythm lane button pressed
- **lane_released(lane_id: int, timestamp: float)**: Rhythm lane button released
- **button_pressed(action: String)**: Non-rhythm button pressed
- **button_held(action: String, hold_duration: float)**: Button held >0.3s
- **button_released(action: String)**: Button released
- **stick_moved(stick: String, direction: Vector2, magnitude: float)**: Analog stick moved
- **controller_connected(device_id: int)**: Controller plugged in
- **controller_disconnected(device_id: int)**: Controller unplugged

### 5. Input Buffering System

Implement input buffer:
- Store last 10 inputs in array with timestamps
- Each entry: `{ action: String, timestamp: float, type: String }`
- Automatically remove entries older than 200ms (configurable)
- Provide `get_buffer()` method for combo detection (S10)
- Provide `clear_buffer()` method

This enables systems like S10 (Special Moves) to detect button combos.

### 6. Deadzone Filtering

Implement deadzone filtering for analog sticks:
- Apply circular deadzone (not square)
- Deadzone values from input_config.json
- If stick magnitude < deadzone, return Vector2.ZERO
- If stick magnitude >= deadzone, normalize and scale output
- Prevent stick drift at rest

### 7. Cross-Platform Controller Support

Map common controller layouts:
- **Xbox**: A=0, B=1, X=2, Y=3, LB=4, RB=5, etc.
- **PlayStation**: Cross=0, Circle=1, Square=2, Triangle=3, L1=4, R1=5, etc.
- **Nintendo**: B=0, A=1, Y=2, X=3, L=4, R=5, etc.

Auto-detect controller type if possible, or provide in-game selector.

### 8. Integration with S01 (Conductor)

**Optional for this prompt** (can be added later):
- When S01 is complete, timestamp rhythm lane inputs relative to nearest beat
- Store beat offset in input buffer
- This enables rhythm quality evaluation

For now, just timestamp inputs with `Time.get_ticks_msec()`.

### 9. Debug Visualization

Create `res://debug/input_debug_overlay.tscn`:
- Display all button states (pressed/released)
- Show analog stick positions with deadzone visualization
- Display input buffer (last 10 inputs)
- Show controller connection status
- Toggle with debug key (F4 or similar)

### 10. Test Scene Creation

Create `res://tests/test_input.tscn`:
- InputManager autoload reference
- Visual feedback for all button presses (light up on press)
- Analog stick position display
- Input buffer display (scrolling list)
- Deadzone visualization (circle showing deadzone threshold)
- Test with multiple controller types

Test:
- All 4 rhythm lanes register presses
- Button holds detected (hold A for >0.3s)
- Analog stick respects deadzone
- Input buffer stores last 10 inputs
- Controller disconnect/reconnect handled gracefully

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://autoloads/input_manager.gd` - Complete InputManager singleton implementation
   - Full logic with signal emissions, input buffering, deadzone filtering
   - Type hints, documentation, error handling
   - Integration with controller events

2. **Create all JSON data files** using the Write tool
   - `res://data/input_config.json` - Complete input configuration (rhythm lanes, deadzones, action mappings)
   - Valid JSON format with all required fields

3. **Create HANDOFF-S02.md** documenting:
   - Scene structures needed (test scene, debug overlay)
   - MCP agent tasks (use GDAI tools)
   - Property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- `res://autoloads/input_manager.gd` - Complete InputManager implementation
- `res://data/input_config.json` - Input configuration data
- `HANDOFF-S02.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)
- Register autoload in project settings (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S02.md
2. Use GDAI tools to configure scenes:
   - Register InputManager as autoload in project settings
   - `create_scene` - Create test_input.tscn and input_debug_overlay.tscn
   - `add_node` - Build node hierarchies for test scenes
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set node properties
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S02.md` with this structure:

```markdown
# System S02 Handoff - Controller Input System

**Created by:** Claude Code Web
**Date:** [timestamp]
**Status:** Ready for MCP Agent Configuration

---

## Files Created (Tier 1 Complete)

### GDScript Files
- `res://autoloads/input_manager.gd` - InputManager singleton with signal emissions, input buffering, deadzone filtering, cross-platform controller support

### Data Files
- `res://data/input_config.json` - Rhythm lane mappings, deadzones, action mappings, input buffer configuration

---

## Scene Configuration Needed (Tier 2 - MCP Agent Tasks)

### Autoload Registration

**MCP Agent Task:**
Register InputManager as autoload singleton in Project Settings:
```gdscript
# Add to Project Settings → Autoload
# Autoload Name: InputManager
# Script Path: res://autoloads/input_manager.gd
# Order: 2 (after Conductor)
```

### Scene 1: `res://tests/test_input.tscn`

**MCP Agent Commands:**
```bash
# Create test scene
create_scene res://tests/test_input.tscn

# Add UI elements for testing
add_node res://tests/test_input.tscn Panel MainPanel root
add_node res://tests/test_input.tscn VBoxContainer ButtonDisplay MainPanel
add_node res://tests/test_input.tscn Label Lane0Label ButtonDisplay
add_node res://tests/test_input.tscn Label Lane1Label ButtonDisplay
add_node res://tests/test_input.tscn Label Lane2Label ButtonDisplay
add_node res://tests/test_input.tscn Label Lane3Label ButtonDisplay
add_node res://tests/test_input.tscn Label StickLabel ButtonDisplay
add_node res://tests/test_input.tscn Panel BufferPanel root
add_node res://tests/test_input.tscn VBoxContainer BufferDisplay BufferPanel
add_node res://tests/test_input.tscn Label BufferTitle BufferDisplay
add_node res://tests/test_input.tscn ColorRect DeadzoneVisual root

# Configure properties
update_property res://tests/test_input.tscn MainPanel position "Vector2(10, 10)"
update_property res://tests/test_input.tscn MainPanel size "Vector2(300, 200)"
update_property res://tests/test_input.tscn BufferPanel position "Vector2(10, 220)"
update_property res://tests/test_input.tscn BufferPanel size "Vector2(300, 250)"
update_property res://tests/test_input.tscn DeadzoneVisual position "Vector2(400, 100)"
update_property res://tests/test_input.tscn DeadzoneVisual size "Vector2(200, 200)"
update_property res://tests/test_input.tscn DeadzoneVisual color "Color(0.5, 0.5, 0.5, 0.3)"
```

**Node Hierarchy:**
```
TestInput (Node2D)
├── MainPanel (Panel)
│   └── ButtonDisplay (VBoxContainer)
│       ├── Lane0Label (Label) - "Lane 0 (A): Not Pressed"
│       ├── Lane1Label (Label) - "Lane 1 (B): Not Pressed"
│       ├── Lane2Label (Label) - "Lane 2 (X): Not Pressed"
│       ├── Lane3Label (Label) - "Lane 3 (Y): Not Pressed"
│       └── StickLabel (Label) - "Left Stick: (0, 0)"
├── BufferPanel (Panel)
│   └── BufferDisplay (VBoxContainer)
│       └── BufferTitle (Label) - "Input Buffer (Last 10):"
└── DeadzoneVisual (ColorRect) - Visual deadzone circle
```

**Property Configurations:**
- Lane0Label through Lane3Label: Light up green when pressed, show hold duration if >0.3s
- StickLabel: Display analog stick position with deadzone applied
- BufferDisplay: Scrolling list of last 10 inputs with timestamps
- DeadzoneVisual: Circle showing deadzone threshold (gray circle with stick position dot)

### Scene 2: `res://debug/input_debug_overlay.tscn`

**MCP Agent Commands:**
```bash
# Create debug overlay scene
create_scene res://debug/input_debug_overlay.tscn

# Add debug UI elements
add_node res://debug/input_debug_overlay.tscn Panel DebugPanel root
add_node res://debug/input_debug_overlay.tscn VBoxContainer DebugInfo DebugPanel
add_node res://debug/input_debug_overlay.tscn Label ControllerStatusLabel DebugInfo
add_node res://debug/input_debug_overlay.tscn Label BufferSizeLabel DebugInfo
add_node res://debug/input_debug_overlay.tscn Label DeadzoneLabel DebugInfo
add_node res://debug/input_debug_overlay.tscn Label LastInputLabel DebugInfo

# Configure properties
update_property res://debug/input_debug_overlay.tscn DebugPanel position "Vector2(10, 10)"
update_property res://debug/input_debug_overlay.tscn DebugPanel size "Vector2(300, 120)"
update_property res://debug/input_debug_overlay.tscn root layer 100
```

**Node Hierarchy:**
```
InputDebugOverlay (CanvasLayer)
└── DebugPanel (Panel)
    └── DebugInfo (VBoxContainer)
        ├── ControllerStatusLabel (Label) - "Controller: Connected (Xbox)"
        ├── BufferSizeLabel (Label) - "Buffer: 5/10 entries"
        ├── DeadzoneLabel (Label) - "Deadzone: 0.2"
        └── LastInputLabel (Label) - "Last Input: lane_0 @ 1234ms"
```

---

## Integration Points

### Signals Exposed:
- `lane_pressed(lane_id: int, timestamp: float)` - Rhythm lane button pressed
- `lane_released(lane_id: int, timestamp: float)` - Rhythm lane button released
- `button_pressed(action: String)` - Non-rhythm button pressed
- `button_held(action: String, hold_duration: float)` - Button held >0.3s
- `button_released(action: String)` - Button released
- `stick_moved(stick: String, direction: Vector2, magnitude: float)` - Analog stick moved
- `controller_connected(device_id: int)` - Controller plugged in
- `controller_disconnected(device_id: int)` - Controller unplugged

### Public Methods:
- `get_buffer() -> Array[Dictionary]` - Returns last 10 inputs for combo detection
- `clear_buffer()` - Clear input buffer
- `is_action_pressed(action: String) -> bool` - Check if action is currently pressed
- `get_stick_input(stick: String) -> Vector2` - Get analog stick position with deadzone applied
- `remap_action(action: String, new_button: String)` - Runtime input remapping

### Dependencies:
- Depends on: None (foundation system)
- Depended on by: S03, S04, S09, S10, S14, S16

---

## Testing Checklist (MCP Agent)

After scene configuration, test with:

```bash
# Play test scene
play_scene res://tests/test_input.tscn

# Check for errors
get_godot_errors
```

### Verify:
- [ ] InputManager autoload is accessible globally
- [ ] input_config.json loads correctly
- [ ] All 4 rhythm lanes register presses (A/B/X/Y buttons)
- [ ] lane_pressed signal emits with correct lane_id and timestamp
- [ ] lane_released signal emits when button released
- [ ] Button holds detected after >0.3s (hold A button and verify)
- [ ] button_held signal emits after hold threshold
- [ ] Analog sticks report movement with deadzone applied
- [ ] Stick position shows Vector2.ZERO when stick at rest (no drift)
- [ ] stick_moved signal emits with direction and magnitude
- [ ] Input buffer stores last 10 inputs with timestamps
- [ ] Buffer auto-removes entries older than 200ms
- [ ] Deadzone prevents stick drift (verify stick at rest shows (0, 0))
- [ ] Controller disconnect/reconnect handled gracefully (unplug/replug controller)
- [ ] Works with Xbox controller layout
- [ ] Works with PlayStation controller layout (if available)
- [ ] Debug overlay displays all input states accurately (toggle with F4)

---

## Notes / Gotchas

- **SDL3 Support**: Godot 4.5 uses SDL3 natively - no external plugins needed for gamepad support
- **Autoload Order**: InputManager should load after Conductor (if S01 complete) but before other gameplay systems
- **Deadzone Type**: Circular deadzone is used (not square) for more natural stick feel
- **Input Buffer**: Retention time is 200ms by default - tune in input_config.json if combos feel tight
- **Controller Layouts**: Button mappings auto-detect controller type, but manual override is available
- **Timing Integration**: When S01 (Conductor) is complete, integrate beat timestamps with input timestamps for rhythm evaluation

---

**Next Steps:** MCP agent should execute all commands above, then update COORDINATION-DASHBOARD.md to mark S02 complete and unblock S03, S04, S09, S10, S14, S16.
```

</handoff_requirements>

<implementation_steps>

Follow this workflow:

1. **Research** (allocate 20% of time)
   - Web search for Godot gamepad patterns
   - Study InputEventJoypadButton API
   - Understand SDL3 controller support in Godot 4.5
   - Take notes on deadzone implementations

2. **InputManager Script** (allocate 35% of time)
   - Create input_manager.gd using Godot MCP
   - Implement _input() or _unhandled_input() for event handling
   - Implement signal emissions for all input types
   - Implement input buffering system
   - Implement deadzone filtering
   - Load configuration from JSON

3. **Configuration** (allocate 10% of time)
   - Create input_config.json with all mappings
   - Verify JSON loads correctly
   - Test changing values updates behavior

4. **Cross-Platform Support** (allocate 10% of time)
   - Test with Xbox controller
   - Test with PlayStation controller (if available)
   - Verify button mappings are correct
   - Handle controller connect/disconnect

5. **Debug Tools** (allocate 10% of time)
   - Create input debug overlay scene
   - Visual button state display
   - Analog stick visualization
   - Input buffer scrolling display
   - Toggle mechanism

6. **Test Scene** (allocate 10% of time)
   - Create test_input.tscn
   - Visual feedback for all inputs
   - Deadzone testing
   - Buffer display
   - Run tests with different controllers

7. **Verification** (allocate 5% of time)
   - Run all verification criteria (see below)
   - Document any controller-specific issues
   - Ensure signals emit correctly

8. **Memory Checkpoint** (quick save)
   - Save progress to Basic Memory MCP
   - Document files created and key decisions

</implementation_steps>

<data_driven_architecture>

To add new button mappings:
```json
"action_mappings": {
  "new_action": { "type": "button", "button": "joy_button_7" }
}
```

To adjust deadzones:
```json
"deadzones": {
  "left_stick": 0.15,  // Smaller = more sensitive
  "right_stick": 0.25   // Larger = less sensitive
}
```

To change rhythm lane mappings:
```json
"rhythm_lanes": [
  { "lane_id": 0, "button": "joy_button_4", "label": "LB", "color": "#FF00FF" }
]
```

All future input requirements can be added to input_config.json without code changes.

</data_driven_architecture>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S02.md, verify:

### Code Quality
- [ ] input_manager.gd created with complete implementation (no TODOs or placeholders)
- [ ] input_config.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented where needed
- [ ] All signals implemented (lane_pressed, lane_released, button_pressed, button_held, button_released, stick_moved, controller_connected, controller_disconnected)
- [ ] Input buffering logic implemented
- [ ] Deadzone filtering logic implemented
- [ ] Controller layout mappings documented

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (autoloads/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S02.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] All rhythm lane mappings configurable from input_config.json
- [ ] All action mappings configurable from input_config.json
- [ ] Deadzone values configurable from JSON
- [ ] Input buffer size and retention time configurable
- [ ] No hardcoded button mappings in script

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] InputManager registered as autoload in project settings
- [ ] test_input.tscn created using `create_scene`
- [ ] All test scene nodes added using `add_node`
- [ ] Properties configured using `update_property`
- [ ] input_debug_overlay.tscn created (if applicable)

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S02")`
- [ ] Quality gates passed: `check_quality_gates("S02")`
- [ ] Checkpoint validated: `validate_checkpoint("S02")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] InputManager autoload accessible globally
- [ ] input_config.json loads correctly
- [ ] All 4 rhythm lanes respond to button presses
- [ ] lane_pressed signal emits with correct lane_id and timestamp
- [ ] Button holds detected (press and hold A for >0.3s)
- [ ] button_held signal emits after hold threshold
- [ ] Analog sticks report movement with deadzone applied
- [ ] stick_moved signal emits with direction and magnitude
- [ ] Input buffer stores last 10 inputs with timestamps
- [ ] Buffer auto-removes entries older than 200ms
- [ ] Deadzone prevents stick drift (test at controller rest)
- [ ] Controller disconnect/reconnect handled gracefully
- [ ] Works with Xbox controller layout
- [ ] Works with PlayStation controller layout (if available)
- [ ] Debug overlay displays all input states accurately (if implemented)

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ input_manager.gd complete with all signal emissions and input logic
- ✅ input_config.json complete with rhythm lanes, deadzones, action mappings
- ✅ All code documented with type hints and comments
- ✅ Input buffering and deadzone filtering implemented
- ✅ HANDOFF-S02.md provides clear MCP agent instructions
- ✅ All mappings configurable from JSON (no hardcoding)

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ InputManager registered as autoload and accessible globally
- ✅ Test scenes configured correctly in Godot editor
- ✅ All controller input is captured - buttons, sticks, triggers
- ✅ Signals are reliable - no missed inputs, no false positives
- ✅ Deadzone works - no stick drift, but still responsive
- ✅ Input buffer is functional - combo systems can query past inputs
- ✅ Cross-platform - works with multiple controller types
- ✅ System ready for dependent systems (S03, S04, S09, S10, S14, S16)

This system is the foundation for all player interaction. It must be responsive and reliable.

</success_criteria>

<memory_checkpoint_format>

When complete, save to Basic Memory MCP:

```
System S02 (Controller Input) Complete

FILES CREATED:
- res://autoloads/input_manager.gd (InputManager singleton)
- res://data/input_config.json (Button mappings, deadzones, buffer config)
- res://tests/test_input.tscn (Test scene with visual feedback)
- res://debug/input_debug_overlay.tscn (Debug visualization)

SIGNALS EXPOSED:
- lane_pressed(lane_id, timestamp)
- lane_released(lane_id, timestamp)
- button_pressed(action)
- button_held(action, hold_duration)
- button_released(action)
- stick_moved(stick, direction, magnitude)
- controller_connected(device_id)
- controller_disconnected(device_id)

KEY METHODS:
- get_buffer() -> Array[Dictionary] (last 10 inputs)
- clear_buffer()
- is_action_pressed(action) -> bool
- get_stick_input(stick) -> Vector2

INPUT BUFFER:
- Max size: 10 entries
- Retention time: 200ms
- Entry format: { action, timestamp, type }

DEADZONES:
- Left stick: 0.2 (configurable)
- Right stick: 0.2 (configurable)
- Triggers: 0.1 (configurable)

CONTROLLER SUPPORT:
- Xbox layout: Tested and working
- PlayStation layout: Tested and working
- Nintendo layout: Button mappings configured

INTEGRATION NOTES:
- S03 (Player Controller) can now read movement input
- S04 (Combat) can now read combat button input
- S10 (Special Moves) can query input buffer for combos
- Integration with S01 (Conductor) pending - timestamps currently use Time.get_ticks_msec()

NEXT DEPENDENCIES:
- S03 (Player Controller) can now implement movement
- S04 (Combat Prototype) can now implement combat input
- S09, S10, S14, S16 can integrate when ready

STATUS: Ready for dependent systems
```

</memory_checkpoint_format>

<important_notes>

## Token Budget: ~8,000 tokens

Optimize by:
- Referencing Godot Input API docs (don't explain entire API)
- Using JSON template (don't describe every field)
- Concise implementation steps
- MCP commands over manual operations

## Parallelization

This system is **INDEPENDENT** and can run in parallel with:
- **S01**: Conductor/Rhythm System
- **S03**: Player Controller (until S03 needs S02)
- **002**: Combat Specification (pure design work)

It **BLOCKS** these systems (they need S02 complete):
- S03, S04, S09, S10, S14, S16

## Critical Success Factors

1. **Responsiveness**: Input must feel immediate, no lag
2. **Accuracy**: Deadzone prevents drift without sacrificing precision
3. **Reliability**: No missed inputs, no ghost inputs
4. **Extensibility**: Easy to add new button mappings or input types

</important_notes>
