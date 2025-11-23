# HANDOFF: S18 - Polyrhythmic Environment

**System:** S18 - Polyrhythmic Environment
**Tier 1 Status:** ✅ Complete
**Created:** 2025-11-18
**Dependencies:** S01 (Conductor - rhythm system)

---

## Files Created by Claude Code Web (Tier 1)

### GDScript Files

All files created with complete implementations, full type hints, and GDScript 4.5 compliance:

1. **`res://environment/polyrhythm_controller.gd`** - Main polyrhythm pattern calculator
   - Calculates complex polyrhythmic patterns (4:3, 5:4, 7:4, etc.)
   - Connects to Conductor (S01) for base beat timing
   - Emits signals for numerator beats, denominator beats, and cycle completion
   - Activates/deactivates patterns dynamically
   - Tracks pattern state and cycle counts

2. **`res://environment/polyrhythm_light.gd`** - Light pulsing on polyrhythm beats
   - Pulses Light2D/PointLight2D brightness on polyrhythm beats
   - Configurable pulse duration, brightness range, and colors
   - Supports numerator or denominator track following
   - Smooth tween-based animations
   - Auto-connects to PolyrhythmController

3. **`res://environment/polyrhythm_machinery.gd`** - Machinery animation on polyrhythm
   - Supports multiple animation types: rotate, move_horizontal, move_vertical, scale_pulse
   - Configurable animation duration and easing
   - Return to origin after animation (optional)
   - Follows polyrhythm patterns
   - Auto-connects to PolyrhythmController

4. **`res://environment/timing_platform.gd`** - Rise/fall timing platforms for puzzles
   - Platform rises/lowers on polyrhythm beats
   - Configurable rise height, duration, and behavior (rise_on_beat, lower_on_beat, toggle)
   - Collision enabled only when raised (optional)
   - Visual feedback with color changes
   - Timed raised duration with auto-lower
   - Extends AnimatableBody2D for physics integration

### Data Files

5. **`res://data/polyrhythm_config.json`** - Polyrhythm pattern definitions
   - 7 polyrhythm patterns: 4:3, 5:4, 7:4, 3:2, 2:3, 6:5, 8:7
   - Element type configurations (light, machinery, platform, door, ambient)
   - Difficulty settings for platforms (easy, medium, hard, expert)
   - Audio integration settings
   - Visual feedback settings
   - Puzzle integration settings
   - Performance and debug settings

---

## System Architecture

### Signal Flow

```
Conductor (S01)
    ↓ beat signal
PolyrhythmController
    ↓ polyrhythm_numerator_beat
    ↓ polyrhythm_denominator_beat
    ↓ polyrhythm_cycle_complete
PolyrhythmLight / PolyrhythmMachinery / TimingPlatform
    ↓ animations/effects
Visual/Audio Feedback
```

### Key Integration Points

1. **S01 Conductor Integration:**
   - PolyrhythmController connects to `/root/Conductor` autoload
   - Listens to `beat(beat_number)` signal from Conductor
   - Calculates polyrhythm positions based on beat timing

2. **Pattern Activation:**
   - Each element (light, machinery, platform) can activate its own pattern
   - PolyrhythmController tracks active patterns and emits signals
   - Elements listen to specific pattern signals

3. **Godot 4.5 Features Used:**
   - Tweens for smooth animations
   - Signals for event-driven architecture
   - AnimatableBody2D for platforms
   - Light2D/PointLight2D for lighting effects

---

## MCP Agent Tasks (Tier 2)

### Prerequisites

Before starting, ensure:
- [ ] Godot 4.5.1 editor is open
- [ ] S01 (Conductor) is implemented and available as autoload
- [ ] GDAI Godot-MCP plugin is connected

---

### Task 1: Setup PolyrhythmController as Autoload

The PolyrhythmController needs to be available globally for all elements to connect to it.

```bash
# Open project settings via execute_editor_script
execute_editor_script "
var settings = ProjectSettings
settings.set_setting('autoload/PolyrhythmController', 'res://environment/polyrhythm_controller.gd')
settings.save()
print('PolyrhythmController added as autoload')
"
```

**Verification:**
- Check that `PolyrhythmController` appears in Project > Project Settings > Autoload
- Verify it loads without errors using `get_godot_errors`

---

### Task 2: Create Polyrhythmic Light Scene

Create a reusable light scene that pulses on polyrhythm beats.

```bash
# Create base scene
create_scene res://environment/polyrhythm_light.tscn Node2D

# Add Light2D
add_node res://environment/polyrhythm_light.tscn Light2D LightNode root

# Add visual sprite (optional, for editor visibility)
add_node res://environment/polyrhythm_light.tscn Sprite2D LightGlow root

# Attach the script to root
attach_script res://environment/polyrhythm_light.tscn root res://environment/polyrhythm_light.gd

# Configure light properties
update_property res://environment/polyrhythm_light.tscn LightNode energy 0.5
update_property res://environment/polyrhythm_light.tscn LightNode color "#FFD700"
update_property res://environment/polyrhythm_light.tscn LightNode texture_scale 2.0

# Configure script parameters
update_property res://environment/polyrhythm_light.tscn root rhythm_pattern "4:3"
update_property res://environment/polyrhythm_light.tscn root rhythm_track "numerator"
update_property res://environment/polyrhythm_light.tscn root base_energy 0.5
update_property res://environment/polyrhythm_light.tscn root peak_energy 1.5
update_property res://environment/polyrhythm_light.tscn root pulse_duration 0.2
update_property res://environment/polyrhythm_light.tscn root auto_start true
```

**Verification:**
- Open `polyrhythm_light.tscn` in editor
- Check script is attached and properties are set
- Verify no errors in `get_godot_errors`

---

### Task 3: Create Polyrhythmic Machinery Scene

Create a machinery object that animates on polyrhythm beats.

```bash
# Create base scene
create_scene res://environment/polyrhythm_machinery.tscn Node2D

# Add visual sprite (gear/machinery graphic)
add_node res://environment/polyrhythm_machinery.tscn Sprite2D Gear root

# Add AnimationPlayer for advanced animations (optional)
add_node res://environment/polyrhythm_machinery.tscn AnimationPlayer Animator root

# Attach the script to root
attach_script res://environment/polyrhythm_machinery.tscn root res://environment/polyrhythm_machinery.gd

# Configure script parameters
update_property res://environment/polyrhythm_machinery.tscn root animation_type "rotate"
update_property res://environment/polyrhythm_machinery.tscn root rhythm_pattern "5:4"
update_property res://environment/polyrhythm_machinery.tscn root rhythm_track "numerator"
update_property res://environment/polyrhythm_machinery.tscn root rotation_angle 90.0
update_property res://environment/polyrhythm_machinery.tscn root animation_duration 0.3
update_property res://environment/polyrhythm_machinery.tscn root return_to_origin true
update_property res://environment/polyrhythm_machinery.tscn root auto_start true
```

**Verification:**
- Open `polyrhythm_machinery.tscn` in editor
- Check script is attached
- Verify properties are configured

---

### Task 4: Create Timing Platform Scene

Create a platform that rises/falls on polyrhythm beats for puzzle mechanics.

```bash
# Create base scene (AnimatableBody2D for physics)
create_scene res://environment/timing_platform.tscn AnimatableBody2D

# Add platform sprite
add_node res://environment/timing_platform.tscn Sprite2D PlatformSprite root

# Add collision shape
add_node res://environment/timing_platform.tscn CollisionShape2D Collision root

# Attach the script to root
attach_script res://environment/timing_platform.tscn root res://environment/timing_platform.gd

# Configure script parameters
update_property res://environment/timing_platform.tscn root rhythm_pattern "4:3"
update_property res://environment/timing_platform.tscn root rhythm_track "numerator"
update_property res://environment/timing_platform.tscn root behavior "toggle_on_beat"
update_property res://environment/timing_platform.tscn root rise_height 100.0
update_property res://environment/timing_platform.tscn root move_duration 0.5
update_property res://environment/timing_platform.tscn root raised_duration 1.0
update_property res://environment/timing_platform.tscn root collision_only_when_raised true
update_property res://environment/timing_platform.tscn root auto_start true

# Configure collision shape (placeholder - replace with actual shape)
add_resource res://environment/timing_platform.tscn Collision shape RectangleShape2D
update_property res://environment/timing_platform.tscn Collision/shape size "Vector2(64, 16)"

# Configure sprite (placeholder - replace with actual sprite)
update_property res://environment/timing_platform.tscn PlatformSprite modulate "#FFFFFF"
```

**Verification:**
- Open `timing_platform.tscn` in editor
- Check AnimatableBody2D is root node
- Verify collision shape exists
- Check script properties

---

### Task 5: Create Test Scene

Create a test scene to demonstrate all polyrhythmic elements working together.

```bash
# Create test scene
create_scene res://tests/test_polyrhythm.tscn Node2D

# Add Conductor instance if not autoloaded in test
# (Skip if Conductor is already autoloaded)
add_node res://tests/test_polyrhythm.tscn Node Conductor root res://src/systems/s01-conductor-rhythm-system/conductor.gd

# Add multiple lights with different patterns
add_scene res://tests/test_polyrhythm.tscn PolyrhythmLight Light1 root res://environment/polyrhythm_light.tscn
add_scene res://tests/test_polyrhythm.tscn PolyrhythmLight Light2 root res://environment/polyrhythm_light.tscn
add_scene res://tests/test_polyrhythm.tscn PolyrhythmLight Light3 root res://environment/polyrhythm_light.tscn

# Add machinery with different patterns
add_scene res://tests/test_polyrhythm.tscn PolyrhythmMachinery Machinery1 root res://environment/polyrhythm_machinery.tscn
add_scene res://tests/test_polyrhythm.tscn PolyrhythmMachinery Machinery2 root res://environment/polyrhythm_machinery.tscn

# Add timing platforms
add_scene res://tests/test_polyrhythm.tscn TimingPlatform Platform1 root res://environment/timing_platform.tscn
add_scene res://tests/test_polyrhythm.tscn TimingPlatform Platform2 root res://environment/timing_platform.tscn
add_scene res://tests/test_polyrhythm.tscn TimingPlatform Platform3 root res://environment/timing_platform.tscn

# Position elements for visibility
update_property res://tests/test_polyrhythm.tscn Light1 position "Vector2(100, 100)"
update_property res://tests/test_polyrhythm.tscn Light2 position "Vector2(300, 100)"
update_property res://tests/test_polyrhythm.tscn Light3 position "Vector2(500, 100)"

update_property res://tests/test_polyrhythm.tscn Machinery1 position "Vector2(100, 300)"
update_property res://tests/test_polyrhythm.tscn Machinery2 position "Vector2(300, 300)"

update_property res://tests/test_polyrhythm.tscn Platform1 position "Vector2(100, 500)"
update_property res://tests/test_polyrhythm.tscn Platform2 position "Vector2(300, 500)"
update_property res://tests/test_polyrhythm.tscn Platform3 position "Vector2(500, 500)"

# Configure different patterns for each element
update_property res://tests/test_polyrhythm.tscn Light1 rhythm_pattern "4:3"
update_property res://tests/test_polyrhythm.tscn Light2 rhythm_pattern "5:4"
update_property res://tests/test_polyrhythm.tscn Light3 rhythm_pattern "3:2"

update_property res://tests/test_polyrhythm.tscn Machinery1 rhythm_pattern "5:4"
update_property res://tests/test_polyrhythm.tscn Machinery1 animation_type "rotate"

update_property res://tests/test_polyrhythm.tscn Machinery2 rhythm_pattern "7:4"
update_property res://tests/test_polyrhythm.tscn Machinery2 animation_type "scale_pulse"

update_property res://tests/test_polyrhythm.tscn Platform1 rhythm_pattern "4:3"
update_property res://tests/test_polyrhythm.tscn Platform2 rhythm_pattern "5:4"
update_property res://tests/test_polyrhythm.tscn Platform3 rhythm_pattern "3:2"

# Add camera for better view
add_node res://tests/test_polyrhythm.tscn Camera2D Camera root
update_property res://tests/test_polyrhythm.tscn Camera position "Vector2(300, 300)"
```

**Verification:**
- Open `test_polyrhythm.tscn` in editor
- Check all elements are positioned correctly
- Verify different patterns are assigned

---

### Task 6: Test in Godot Editor

Run the test scene and verify polyrhythm functionality.

```bash
# Play the test scene
play_scene res://tests/test_polyrhythm.tscn

# Wait for scene to run, then check for errors
get_godot_errors

# Take screenshot of running scene
get_running_scene_screenshot
```

**Manual Verification Checklist:**

- [ ] Conductor is running and emitting beat signals
- [ ] PolyrhythmController is calculating patterns correctly
- [ ] Lights pulse on their respective polyrhythm beats:
  - [ ] Light1 (4:3 pattern) - 4 pulses over 3 beats
  - [ ] Light2 (5:4 pattern) - 5 pulses over 4 beats
  - [ ] Light3 (3:2 pattern) - 3 pulses over 2 beats
- [ ] Machinery animates on polyrhythm beats:
  - [ ] Machinery1 rotates on 5:4 pattern
  - [ ] Machinery2 scales on 7:4 pattern
- [ ] Timing platforms rise/fall on pattern:
  - [ ] Platform1 toggles on 4:3 pattern
  - [ ] Platform2 toggles on 5:4 pattern
  - [ ] Platform3 toggles on 3:2 pattern
- [ ] Visual feedback is clear and synchronized
- [ ] No errors in output console

```bash
# Stop the scene
stop_running_scene
```

---

### Task 7: Integration Verification

Verify integration with S01 Conductor system.

```bash
# Check Conductor autoload exists
execute_editor_script "
if Engine.has_singleton('Conductor'):
    print('Conductor singleton found')
else:
    print('ERROR: Conductor singleton not found')

var conductor = get_node('/root/Conductor')
if conductor:
    print('Conductor accessible: ', conductor.get_class())
    print('Current BPM: ', conductor.get_bpm())
else:
    print('ERROR: Cannot access Conductor')
"

# Check PolyrhythmController autoload
execute_editor_script "
var poly_controller = get_node('/root/PolyrhythmController')
if poly_controller:
    print('PolyrhythmController accessible')
    print('Active patterns: ', poly_controller.get_active_patterns())
else:
    print('ERROR: Cannot access PolyrhythmController')
"
```

---

### Task 8: Performance Testing

Test with multiple elements to ensure performance is acceptable.

```bash
# Create performance test scene with many elements
create_scene res://tests/test_polyrhythm_performance.tscn Node2D

# Add 20 lights, 10 machinery, 5 platforms
# (Abbreviated for brevity - expand as needed)

# Run scene and check performance
play_scene res://tests/test_polyrhythm_performance.tscn

# Monitor FPS and performance
execute_editor_script "
print('FPS: ', Engine.get_frames_per_second())
print('Process time: ', Performance.get_monitor(Performance.TIME_PROCESS))
"
```

**Performance Targets:**
- [ ] 60 FPS with 20+ elements
- [ ] No frame drops during beat emissions
- [ ] Smooth tween animations

---

### Task 9: Update COORDINATION-DASHBOARD.md

Mark S18 as complete and update progress.

```bash
# Use editor script to note completion
execute_editor_script "
print('S18 Polyrhythmic Environment - COMPLETE')
print('Files created:')
print('  - polyrhythm_controller.gd')
print('  - polyrhythm_light.gd')
print('  - polyrhythm_machinery.gd')
print('  - timing_platform.gd')
print('  - polyrhythm_config.json')
print('Scenes created:')
print('  - polyrhythm_light.tscn')
print('  - polyrhythm_machinery.tscn')
print('  - timing_platform.tscn')
print('  - test_polyrhythm.tscn')
print('Status: Ready for Job 4 (S19-S26)')
"
```

Manually update `COORDINATION-DASHBOARD.md`:
- Mark S18 as ✅ Complete
- Note completion date
- Add to "Recent Activity" section

---

## Testing Checklist

### Functional Testing

- [ ] **PolyrhythmController:**
  - [ ] Loads config from JSON successfully
  - [ ] Connects to Conductor autoload
  - [ ] Activates patterns correctly
  - [ ] Calculates beat positions for 4:3, 5:4, 7:4 patterns
  - [ ] Emits numerator_beat and denominator_beat signals
  - [ ] Tracks cycle completion

- [ ] **PolyrhythmLight:**
  - [ ] Finds Light2D/PointLight2D child node
  - [ ] Connects to PolyrhythmController
  - [ ] Pulses brightness on polyrhythm beats
  - [ ] Tweens smoothly between base and peak energy
  - [ ] Colors change during pulse
  - [ ] Follows correct rhythm track (numerator/denominator)

- [ ] **PolyrhythmMachinery:**
  - [ ] Rotation animation works
  - [ ] Horizontal movement works
  - [ ] Vertical movement works
  - [ ] Scale pulse works
  - [ ] Returns to origin after animation
  - [ ] Follows polyrhythm beats correctly

- [ ] **TimingPlatform:**
  - [ ] Rises on beat
  - [ ] Lowers on beat
  - [ ] Toggles on beat
  - [ ] Collision enabled/disabled based on state
  - [ ] Visual feedback (color changes)
  - [ ] Stays raised for configured duration
  - [ ] Auto-lowers after timer

### Integration Testing

- [ ] **S01 Integration:**
  - [ ] PolyrhythmController receives Conductor beat signals
  - [ ] Polyrhythm calculations sync with Conductor BPM
  - [ ] BPM changes propagate correctly

### Visual Testing

- [ ] Lights pulse visibly and rhythmically
- [ ] Machinery animations are smooth and noticeable
- [ ] Platform movement is clear and predictable
- [ ] Multiple elements don't visually clash
- [ ] Polyrhythm feel is musically accurate

### Audio Testing (Optional - if sounds added)

- [ ] Numerator beat sounds play correctly
- [ ] Denominator beat sounds play correctly
- [ ] Cycle complete sounds play correctly
- [ ] Sound volume is balanced

---

## Known Issues & Solutions

### Issue: PolyrhythmController not found

**Symptom:** Elements can't connect to PolyrhythmController

**Solution:**
1. Verify PolyrhythmController is added as autoload
2. Check autoload path: `res://environment/polyrhythm_controller.gd`
3. Restart Godot editor after adding autoload

### Issue: Patterns not activating

**Symptom:** No polyrhythm beats emitted

**Solution:**
1. Check Conductor is started: `Conductor.start()`
2. Verify pattern is activated: `PolyrhythmController.activate_pattern("4:3")`
3. Check debug output for errors

### Issue: Tweens not smooth

**Symptom:** Jerky animations

**Solution:**
1. Verify `animation_duration` is > 0.1
2. Check easing settings
3. Ensure no tween conflicts (previous tween not killed)

### Issue: Collision detection problems

**Symptom:** Platform collision not working

**Solution:**
1. Verify CollisionShape2D exists
2. Check `collision_only_when_raised` setting
3. Ensure shape is not disabled in editor

---

## Integration Points

### S01 (Conductor) - Required Dependency

- **Signal Used:** `beat(beat_number: int)`
- **Signal Used:** `measure_complete(measure_number: int)`
- **Method Used:** `get_bpm() -> float`
- **Integration:** PolyrhythmController subscribes to Conductor beat signals

### S17 (Puzzle System) - Optional Integration

- **Future Integration:** TimingPlatform can emit signals for puzzle completion
- **Signals Available:**
  - `player_landed_on_platform()` - Successful timing
  - `player_missed_platform()` - Failed timing
- **Puzzle Use Cases:**
  - Timing-based platform traversal
  - Polyrhythm pattern matching puzzles
  - Multi-platform synchronization challenges

---

## Completion Criteria

### Tier 2 Complete When:

1. ✅ All scenes created and configured
2. ✅ Test scene runs without errors
3. ✅ All polyrhythm patterns work correctly (4:3, 5:4, 7:4, etc.)
4. ✅ Lights pulse on correct beats
5. ✅ Machinery animates on correct beats
6. ✅ Platforms rise/fall on correct beats
7. ✅ Integration with Conductor verified
8. ✅ Performance is acceptable (60 FPS with 20+ elements)
9. ✅ No errors in Godot output
10. ✅ COORDINATION-DASHBOARD.md updated

---

## Framework Quality Gates

Before marking S18 as complete, run these quality checks:

```bash
# Integration tests
IntegrationTestSuite.run_all_tests()

# Performance profiling
PerformanceProfiler.profile_system("S18")

# Quality gate checks
check_quality_gates("S18")

# Checkpoint validation
validate_checkpoint("S18")
```

Expected results:
- All integration tests pass
- Performance within targets (60 FPS)
- Quality score >= 80/100
- Checkpoint valid

---

## Next Steps (Job 4)

With S18 complete, Job 3 (S09-S18) is finished!

**Ready for Job 4:** S19-S26 (Advanced systems)

Systems that can use S18:
- S17 (Puzzle System) - Timing-based puzzles
- S19+ (Advanced gameplay) - Polyrhythmic environments

---

## Debug Commands

Useful commands for testing and debugging:

```bash
# Check PolyrhythmController state
execute_editor_script "
var pc = get_node('/root/PolyrhythmController')
pc.print_debug_info()
"

# List active patterns
execute_editor_script "
var pc = get_node('/root/PolyrhythmController')
print('Active patterns: ', pc.get_active_patterns())
"

# Check Conductor state
execute_editor_script "
var conductor = get_node('/root/Conductor')
conductor.print_debug_info()
"

# Enable debug mode
execute_editor_script "
var pc = get_node('/root/PolyrhythmController')
pc.debug_enabled = true
"
```

---

## Summary

**Tier 1 Deliverables:** ✅ All complete
- 4 GDScript files (controller, light, machinery, platform)
- 1 JSON config file
- Full implementations with type hints
- GDScript 4.5 compliance

**Tier 2 Tasks:**
- 9 main tasks (autoload setup, scene creation, testing)
- Comprehensive verification checklist
- Integration testing
- Performance validation

**Status:** Ready for MCP Agent implementation (Tier 2)

---

**End of Handoff**
